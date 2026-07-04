import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import Stripe from "npm:stripe@17.4.0";

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const STRIPE_SECRET = Deno.env.get('STRIPE_SECRET_KEY') || '';

const stripe = STRIPE_SECRET ? new Stripe(STRIPE_SECRET, { apiVersion: '2024-12-18.acacia', httpClient: Stripe.createFetchHttpClient() }) : null;
const admin = createClient(SUPABASE_URL, SERVICE_ROLE);

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'content-type, authorization, x-client-info, apikey',
  'Access-Control-Max-Age': '86400'
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response(null, { headers: CORS });
  if (req.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);
  if (!stripe) return json({ error: 'stripe_not_configured' }, 500);

  const authHeader = req.headers.get('Authorization') || '';
  if (!authHeader.startsWith('Bearer ')) return json({ error: 'unauthorized' }, 401);
  const token = authHeader.slice(7);

  // Lire is_super_admin depuis le JWT (sans appel DB supplémentaire)
  let userId = '';
  let isSuper = false;
  try {
    const payload = JSON.parse(atob(token.split('.')[1]));
    userId = payload.sub || '';
    isSuper = payload.is_super_admin === true;
  } catch (_) {
    return json({ error: 'invalid_token' }, 401);
  }
  if (!userId) return json({ error: 'unauthorized' }, 401);

  // Fallback : si le claim JWT n'est pas présent (token émis avant le hook), vérifier via fonction DB
  if (!isSuper) {
    const { data: rpcOk, error: rpcErr } = await admin.rpc('is_super_admin', { user_id: userId });
    if (rpcErr) return json({ error: 'role_check_failed', detail: rpcErr.message }, 500);
    isSuper = rpcOk === true;
  }

  if (!isSuper) return json({ error: 'forbidden_not_super_admin' }, 403);

  try {
    const body = await req.json();
    const plans = body.plans as Array<{ plan: string; label: string; monthly_eur?: number; annual_eur?: number; description?: string }>;
    if (!Array.isArray(plans) || plans.length === 0) return json({ error: 'plans_requis' }, 400);

    const results: any[] = [];

    for (const p of plans) {
      let product: Stripe.Product;
      const existing = await stripe.products.list({ limit: 100 });
      const found = existing.data.find(x => x.metadata?.mib_plan === p.plan);
      if (found) {
        product = await stripe.products.update(found.id, {
          name: `MIB Prévention — ${p.label}`,
          description: p.description || `Plan ${p.label} pour centres de formation SSIAP.`,
          metadata: { mib_plan: p.plan }
        });
      } else {
        product = await stripe.products.create({
          name: `MIB Prévention — ${p.label}`,
          description: p.description || `Plan ${p.label} pour centres de formation SSIAP.`,
          metadata: { mib_plan: p.plan }
        });
      }

      const cycles: Array<{ cycle: 'mensuel'|'annuel'; interval: 'month'|'year'; eur?: number }> = [
        { cycle: 'mensuel', interval: 'month', eur: p.monthly_eur },
        { cycle: 'annuel',  interval: 'year',  eur: p.annual_eur }
      ];

      for (const c of cycles) {
        if (!c.eur || c.eur <= 0) continue;
        const amount_cents = Math.round(c.eur * 100);

        const { data: oldRows } = await admin.from('stripe_prices').select('stripe_price_id').eq('plan', p.plan).eq('cycle', c.cycle).eq('active', true);
        for (const o of oldRows || []) {
          try { await stripe.prices.update(o.stripe_price_id, { active: false }); } catch {}
        }
        await admin.from('stripe_prices').update({ active: false }).eq('plan', p.plan).eq('cycle', c.cycle).eq('active', true);

        const price = await stripe.prices.create({
          product: product.id,
          unit_amount: amount_cents,
          currency: 'eur',
          recurring: { interval: c.interval },
          metadata: { mib_plan: p.plan, mib_cycle: c.cycle }
        });

        const { error: ierr } = await admin.from('stripe_prices').insert({
          plan: p.plan,
          cycle: c.cycle,
          stripe_price_id: price.id,
          amount_cents,
          currency: 'eur',
          active: true,
          note: `Auto-créé le ${new Date().toISOString()}`
        });
        if (ierr) throw ierr;

        results.push({
          plan: p.plan,
          cycle: c.cycle,
          stripe_product_id: product.id,
          stripe_price_id: price.id,
          amount_eur: c.eur
        });
      }
    }

    return json({ ok: true, count: results.length, results });
  } catch (e) {
    console.error('setup-products error:', e);
    return json({ error: 'server_error', message: String(e?.message || e) }, 500);
  }
});

function json(obj: unknown, status = 200) {
  return new Response(JSON.stringify(obj), { status, headers: { 'Content-Type': 'application/json', ...CORS } });
}
