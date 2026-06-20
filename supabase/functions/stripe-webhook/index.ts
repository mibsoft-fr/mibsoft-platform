import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import Stripe from "npm:stripe@17.4.0";

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const STRIPE_SECRET = Deno.env.get('STRIPE_SECRET_KEY') || '';
const STRIPE_WEBHOOK_SECRET = Deno.env.get('STRIPE_WEBHOOK_SECRET') || '';
const MAILGUN_API_KEY = Deno.env.get('MAILGUN_API_KEY') || '';
const MAILGUN_DOMAIN = Deno.env.get('MAILGUN_DOMAIN') || 'mibsoft.fr';
const MAILGUN_HOST = Deno.env.get('MAILGUN_HOST') || 'api.eu.mailgun.net';
const MAILGUN_FROM = Deno.env.get('MAILGUN_FROM') || `MIB Prévention <noreply@${MAILGUN_DOMAIN}>`;
const APP_URL = Deno.env.get('APP_URL') || 'https://mibsoft.fr';

const stripe = STRIPE_SECRET ? new Stripe(STRIPE_SECRET, { apiVersion: '2024-12-18.acacia', httpClient: Stripe.createFetchHttpClient() }) : null;
const cryptoProvider = Stripe.createSubtleCryptoProvider();

const admin = createClient(SUPABASE_URL, SERVICE_ROLE);

Deno.serve(async (req) => {
  if (!stripe) return new Response('Stripe not configured', { status: 500 });
  if (!STRIPE_WEBHOOK_SECRET) return new Response('Webhook secret missing', { status: 500 });

  const sig = req.headers.get('stripe-signature');
  if (!sig) return new Response('Missing signature', { status: 400 });
  const body = await req.text();

  let event: Stripe.Event;
  try {
    event = await stripe.webhooks.constructEventAsync(body, sig, STRIPE_WEBHOOK_SECRET, undefined, cryptoProvider);
  } catch (e) {
    return new Response(`Webhook Error: ${e.message}`, { status: 400 });
  }

  const { data: existing } = await admin.from('stripe_events').select('status').eq('id', event.id).maybeSingle();
  if (existing && existing.status === 'done') return json({ ok: true, idempotent: true });

  await admin.from('stripe_events').upsert({
    id: event.id,
    event_type: event.type,
    livemode: event.livemode,
    status: 'processing',
    context: { api_version: event.api_version }
  });

  try {
    switch (event.type) {
      case 'checkout.session.completed':
        await handleCheckoutCompleted(event.data.object as Stripe.Checkout.Session);
        break;
      case 'customer.subscription.updated':
        await handleSubscriptionUpdated(event.data.object as Stripe.Subscription);
        break;
      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object as Stripe.Subscription);
        break;
      case 'invoice.payment_failed':
        await handlePaymentFailed(event.data.object as Stripe.Invoice);
        break;
      default:
        await admin.from('stripe_events').update({ status: 'ignored', processed_at: new Date().toISOString() }).eq('id', event.id);
        return json({ ok: true, ignored: true });
    }
    await admin.from('stripe_events').update({ status: 'done', processed_at: new Date().toISOString() }).eq('id', event.id);
    return json({ ok: true });
  } catch (e) {
    await admin.from('stripe_events').update({ status: 'error', processed_at: new Date().toISOString(), error_message: String(e?.message || e) }).eq('id', event.id);
    console.error('webhook handler error:', e);
    return new Response(`Handler error: ${e.message}`, { status: 500 });
  }
});

async function handleCheckoutCompleted(session: Stripe.Checkout.Session) {
  const meta = session.metadata || {};
  const planMeta = (meta.plan || 'starter').toLowerCase();
  const nomCentre = meta.nom_centre || session.customer_details?.name || 'Nouveau centre';
  const email = (session.customer_details?.email || meta.email || '').toLowerCase();
  if (!email) throw new Error('email manquant dans la session');

  let cycle = 'annuel';
  let expiresAt: string | null = null;
  let subscriptionId: string | null = null;
  if (session.mode === 'subscription' && session.subscription) {
    subscriptionId = typeof session.subscription === 'string' ? session.subscription : session.subscription.id;
    const sub = await stripe!.subscriptions.retrieve(subscriptionId);
    cycle = sub.items.data[0]?.price?.recurring?.interval === 'month' ? 'mensuel' : 'annuel';
    expiresAt = new Date(sub.current_period_end * 1000).toISOString();
  } else if (session.mode === 'payment') {
    expiresAt = new Date(Date.now() + 365 * 24 * 3600 * 1000).toISOString();
  }

  const { data: existingCentre } = await admin.from('centers').select('id, auth_user_id').eq('email', email).maybeSingle();
  if (existingCentre) {
    await admin.from('centers').update({
      license_status: 'active',
      license_expires_at: expiresAt,
      billing_cycle: cycle,
      stripe_customer_id: typeof session.customer === 'string' ? session.customer : session.customer?.id,
      stripe_subscription_id: subscriptionId
    }).eq('id', existingCentre.id);
    return;
  }

  const licenseKey = genLicenseKey();
  const quotas = quotasForPlan(planMeta);
  const licenseType = planMeta === 'independant' ? 'formateur' : 'centre';

  const tempPwd = crypto.randomUUID();
  const { data: created, error: cerr } = await admin.auth.admin.createUser({
    email,
    password: tempPwd,
    email_confirm: true,
    user_metadata: { nom_centre: nomCentre, stripe_customer_id: session.customer }
  });
  if (cerr || !created.user) throw new Error('auth_create: ' + cerr?.message);

  const authUserId = created.user.id;

  const { data: centre, error: ierr } = await admin.from('centers').insert({
    auth_user_id: authUserId,
    email,
    nom: nomCentre,
    license_key: licenseKey,
    plan: planMeta,
    license_status: 'active',
    license_type: licenseType,
    billing_cycle: cycle,
    license_expires_at: expiresAt,
    max_formateurs: quotas.max_formateurs,
    max_stagiaires: quotas.max_stagiaires,
    password_set: false,
    stripe_customer_id: typeof session.customer === 'string' ? session.customer : session.customer?.id,
    stripe_subscription_id: subscriptionId
  }).select('id').single();
  if (ierr) {
    await admin.auth.admin.deleteUser(authUserId);
    throw new Error('centre_insert: ' + ierr.message);
  }

  await admin.from('profiles').upsert({
    user_id: authUserId,
    role: licenseType === 'formateur' ? 'formateur' : 'centre',
    center_id: centre.id,
    linked_id: centre.id
  });

  const { data: linkData } = await admin.auth.admin.generateLink({
    type: 'recovery',
    email,
    options: { redirectTo: `${APP_URL}/${licenseType === 'formateur' ? 'login-formateur' : 'login-centre'}.html` }
  });
  const magicLink = linkData?.properties?.action_link || `${APP_URL}/login-centre.html`;

  if (MAILGUN_API_KEY) {
    await sendWelcomeEmail({ email, nomCentre, licenseKey, plan: planMeta, magicLink, licenseType });
  }
}

async function handleSubscriptionUpdated(sub: Stripe.Subscription) {
  const customerId = typeof sub.customer === 'string' ? sub.customer : sub.customer.id;
  const { data: centre } = await admin.from('centers').select('id').eq('stripe_customer_id', customerId).maybeSingle();
  if (!centre) return;
  await admin.from('centers').update({
    license_status: sub.status === 'active' || sub.status === 'trialing' ? 'active' : (sub.status === 'past_due' ? 'suspended' : 'expired'),
    license_expires_at: new Date(sub.current_period_end * 1000).toISOString(),
    stripe_subscription_id: sub.id
  }).eq('id', centre.id);
}

async function handleSubscriptionDeleted(sub: Stripe.Subscription) {
  const customerId = typeof sub.customer === 'string' ? sub.customer : sub.customer.id;
  const { data: centre } = await admin.from('centers').select('id').eq('stripe_customer_id', customerId).maybeSingle();
  if (!centre) return;
  await admin.from('centers').update({ license_status: 'expired' }).eq('id', centre.id);
}

async function handlePaymentFailed(invoice: Stripe.Invoice) {
  const customerId = typeof invoice.customer === 'string' ? invoice.customer : invoice.customer?.id;
  if (!customerId) return;
  const { data: centre } = await admin.from('centers').select('id, nom').eq('stripe_customer_id', customerId).maybeSingle();
  if (!centre) return;
  await admin.from('centers').update({ license_status: 'suspended' }).eq('id', centre.id);
  await admin.from('monitoring_alerts').insert({
    severity: 'warning',
    source: 'stripe',
    title: `Paiement échoué — ${centre.nom}`,
    message: `Facture ${invoice.id} — montant ${(invoice.amount_due/100).toFixed(2)} ${invoice.currency.toUpperCase()}`,
    context: { customer: customerId, invoice: invoice.id, hosted_invoice_url: invoice.hosted_invoice_url }
  });
}

function genLicenseKey(): string {
  const seg = () => Math.random().toString(36).substring(2, 6).toUpperCase();
  return `${seg()}-${seg()}-${seg()}-${seg()}`;
}

function quotasForPlan(plan: string) {
  return ({
    demo:        { max_formateurs: 1,  max_stagiaires: 5 },
    independant: { max_formateurs: 1,  max_stagiaires: 30 },
    starter:     { max_formateurs: 3,  max_stagiaires: 30 },
    pro:         { max_formateurs: 10, max_stagiaires: 100 },
    expert:      { max_formateurs: 20, max_stagiaires: 200 },
    entreprise:  { max_formateurs: 0,  max_stagiaires: 0 }
  } as any)[plan] || { max_formateurs: 5, max_stagiaires: 50 };
}

async function sendWelcomeEmail({ email, nomCentre, licenseKey, plan, magicLink, licenseType }: { email: string; nomCentre: string; licenseKey: string; plan: string; magicLink: string; licenseType: string }) {
  const html = `
    <h2 style="font-family:Georgia,serif;color:#1A2842;">Bienvenue chez MIB Prévention</h2>
    <p>Bonjour,</p>
    <p>Votre paiement pour le plan <strong>${escapeHtml(plan.toUpperCase())}</strong> a été validé. ${licenseType === 'formateur' ? 'Votre compte formateur indépendant' : `Votre centre <strong>${escapeHtml(nomCentre)}</strong>`} est maintenant activé.</p>
    <h3>Vos identifiants</h3>
    <ul>
      <li>Email de connexion : <code>${escapeHtml(email)}</code></li>
      <li>Clé de licence : <code style="background:#f6f1e7;padding:4px 8px;border-radius:4px;font-size:1.1em;font-weight:700;">${escapeHtml(licenseKey)}</code></li>
    </ul>
    <h3>Première connexion</h3>
    <p>Cliquez sur le bouton ci-dessous pour définir votre mot de passe et accéder à votre espace.</p>
    <p style="text-align:center;margin:30px 0;">
      <a href="${escapeHtml(magicLink)}" style="background:#C8102E;color:#fff;padding:12px 30px;text-decoration:none;border-radius:8px;font-weight:700;display:inline-block;">Définir mon mot de passe →</a>
    </p>
    <p style="font-size:.85em;color:#666;">Si le bouton ne fonctionne pas, copiez ce lien dans votre navigateur :<br><code style="font-size:.75em;">${escapeHtml(magicLink)}</code></p>
    <hr style="margin:30px 0;border:none;border-top:1px solid #eee;">
    <p style="font-size:.85em;color:#666;">Une question ? Répondez à cet email.</p>
    <p style="font-size:.85em;color:#666;">MIB Prévention — Formation SSIAP</p>
  `;
  const form = new FormData();
  form.append('from', MAILGUN_FROM);
  form.append('to', email);
  form.append('subject', `Bienvenue chez MIB Prévention — Votre accès ${plan.toUpperCase()}`);
  form.append('html', html);
  const res = await fetch(`https://${MAILGUN_HOST}/v3/${MAILGUN_DOMAIN}/messages`, {
    method: 'POST',
    headers: { 'Authorization': `Basic ${btoa(`api:${MAILGUN_API_KEY}`)}` },
    body: form
  });
  if (!res.ok) {
    const txt = await res.text();
    console.error('mailgun error:', res.status, txt);
  }
}

function json(obj: unknown, status = 200) {
  return new Response(JSON.stringify(obj), { status, headers: { 'Content-Type': 'application/json' } });
}

function escapeHtml(s: string) {
  return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
