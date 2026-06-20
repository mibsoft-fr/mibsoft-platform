import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import Stripe from "npm:stripe@17.4.0";

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const STRIPE_SECRET = Deno.env.get('STRIPE_SECRET_KEY') || '';
const VITRINE_URL_DEFAULT = Deno.env.get('VITRINE_URL') || 'https://mibsoft.fr';

const stripe = STRIPE_SECRET ? new Stripe(STRIPE_SECRET, { apiVersion: '2024-12-18.acacia', httpClient: Stripe.createFetchHttpClient() }) : null;
const admin = createClient(SUPABASE_URL, SERVICE_ROLE);

// Origines autorisées pour CORS + return URL :
// - mibsoft.fr (vitrine + app prod, domaine unique)
// - n'importe quel déploiement Vercel du projet mib-platform-ssiap (preview/prod)
// - localhost pour dev
function isOriginAllowed(origin: string): boolean {
  if (!origin) return false;
  if (origin === 'https://mibsoft.fr') return true;
  if (origin === 'https://www.mibsoft.fr') return true;
  if (origin === 'https://app.mibsoft.fr') return true;
  if (origin === 'http://localhost:8000') return true;
  if (origin === 'http://127.0.0.1:5500') return true;
  // Tous les préviews Vercel du projet (production + preview branches)
  if (/^https:\/\/mib-platform-ssiap[-a-z0-9]*\.vercel\.app$/i.test(origin)) return true;
  if (/^https:\/\/mib-platform-ssiap-git-[-a-z0-9]+-mib-preventions-projects\.vercel\.app$/i.test(origin)) return true;
  if (/^https:\/\/mib-platform-ssiap-[a-z0-9]+-mib-preventions-projects\.vercel\.app$/i.test(origin)) return true;
  return false;
}

function corsHeaders(req: Request) {
  const origin = req.headers.get('origin') || '';
  const allowed = isOriginAllowed(origin);
  return {
    'Access-Control-Allow-Origin': allowed ? origin : 'https://mibsoft.fr',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'content-type, authorization, x-client-info, apikey',
    'Access-Control-Max-Age': '86400',
    'Vary': 'Origin'
  };
}

Deno.serve(async (req) => {
  const cors = corsHeaders(req);
  if (req.method === 'OPTIONS') return new Response(null, { headers: cors });
  if (req.method !== 'POST') return json({ error: 'method_not_allowed' }, 405, cors);
  if (!stripe) return json({ error: 'stripe_not_configured' }, 500, cors);

  try {
    const body = await req.json();
    const plan = String(body.plan || '').toLowerCase();
    const cycle = String(body.cycle || 'annuel').toLowerCase();
    const email = (body.email || '').toLowerCase().trim();
    const nomCentre = (body.nom_centre || body.nomCentre || '').trim();

    const callerOrigin = req.headers.get('origin') || '';
    const returnUrlPrefix = isOriginAllowed(callerOrigin) ? callerOrigin : VITRINE_URL_DEFAULT;

    const allowedPlans = ['independant','starter','pro','expert'];
    if (!allowedPlans.includes(plan)) {
      return json({ error: 'plan_invalide', message: `Plans acceptés : ${allowedPlans.join(', ')}. Pour entreprise contactez-nous.` }, 400, cors);
    }
    if (!['mensuel','annuel'].includes(cycle)) {
      return json({ error: 'cycle_invalide' }, 400, cors);
    }
    if (plan === 'independant' && cycle !== 'mensuel') {
      return json({ error: 'cycle_independant_mensuel_only', message: 'Le plan indépendant est uniquement disponible en mensuel.' }, 400, cors);
    }
    if (!email || !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
      return json({ error: 'email_invalide' }, 400, cors);
    }
    if (!nomCentre || nomCentre.length < 2) {
      return json({ error: 'nom_centre_requis' }, 400, cors);
    }

    const { data: existing } = await admin.from('centers').select('id, license_status, plan').eq('email', email).maybeSingle();
    if (existing && existing.license_status === 'active') {
      return json({ error: 'email_déjà_actif', message: 'Un centre actif existe déjà pour cet email. Connectez-vous ou contactez-nous.' }, 409, cors);
    }

    const { data: priceRow, error: perr } = await admin
      .from('stripe_prices')
      .select('stripe_price_id, amount_cents')
      .eq('plan', plan)
      .eq('cycle', cycle)
      .eq('active', true)
      .maybeSingle();
    if (perr) throw perr;
    if (!priceRow) {
      return json({ error: 'prix_non_configuré', message: 'Ce plan n’est pas encore disponible. Réessayez plus tard.' }, 503, cors);
    }

    const session = await stripe.checkout.sessions.create({
      mode: 'subscription',
      payment_method_types: ['card'],
      line_items: [{ price: priceRow.stripe_price_id, quantity: 1 }],
      customer_email: email,
      client_reference_id: nomCentre.substring(0, 200),
      success_url: `${returnUrlPrefix}/paiement-succes.html?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${returnUrlPrefix}/paiement-annule.html`,
      allow_promotion_codes: true,
      billing_address_collection: 'required',
      locale: 'fr',
      metadata: { plan, cycle, nom_centre: nomCentre, email, source: callerOrigin || 'vitrine' },
      subscription_data: { metadata: { plan, cycle, nom_centre: nomCentre, email } }
    });

    return json({ url: session.url, session_id: session.id }, 200, cors);
  } catch (e) {
    console.error('create-checkout error:', e);
    return json({ error: 'server_error', message: String(e?.message || e) }, 500, cors);
  }
});

function json(obj: unknown, status: number, extraHeaders: Record<string,string> = {}) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { 'Content-Type': 'application/json', ...extraHeaders }
  });
}
