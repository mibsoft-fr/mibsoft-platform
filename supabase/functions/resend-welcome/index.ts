import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const MAILGUN_API_KEY = Deno.env.get('MAILGUN_API_KEY') || '';
const MAILGUN_DOMAIN = Deno.env.get('MAILGUN_DOMAIN') || 'mib-prevention.fr';
const MAILGUN_HOST = Deno.env.get('MAILGUN_HOST') || 'api.eu.mailgun.net';
const MAILGUN_FROM = Deno.env.get('MAILGUN_FROM') || `MIBsoft <noreply@${MAILGUN_DOMAIN}>`;
const APP_URL = Deno.env.get('APP_URL') || 'https://app.mib-prevention.fr';

const admin = createClient(SUPABASE_URL, SERVICE_ROLE);

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'content-type, authorization, apikey'
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response(null, { headers: CORS });
  if (req.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);

  // Auth super-admin
  const authHeader = req.headers.get('Authorization') || '';
  if (!authHeader.startsWith('Bearer ')) return json({ error: 'unauthorized' }, 401);
  const token = authHeader.slice(7);
  let userId = '', isSuper = false;
  try {
    const p = JSON.parse(atob(token.split('.')[1]));
    userId = p.sub || '';
    isSuper = p.is_super_admin === true;
  } catch { return json({ error: 'invalid_token' }, 401); }
  if (!isSuper) {
    const { data } = await admin.rpc('is_super_admin', { user_id: userId });
    isSuper = data === true;
  }
  if (!isSuper) return json({ error: 'forbidden_not_super_admin' }, 403);

  try {
    const body = await req.json();
    const email = String(body.email || '').toLowerCase().trim();
    if (!email) return json({ error: 'email_requis' }, 400);

    const { data: centre, error: cerr } = await admin
      .from('centers')
      .select('id, email, nom, plan, license_key, license_type')
      .eq('email', email)
      .maybeSingle();
    if (cerr) throw cerr;
    if (!centre) return json({ error: 'centre_introuvable' }, 404);

    // Générer un nouveau lien de recovery
    const redirectTo = `${APP_URL}/${centre.license_type === 'formateur' ? 'login-formateur' : 'login-centre'}.html`;
    const { data: linkData, error: lerr } = await admin.auth.admin.generateLink({
      type: 'recovery',
      email,
      options: { redirectTo }
    });
    if (lerr) return json({ error: 'generate_link_failed', detail: lerr.message }, 500);
    const magicLink = linkData?.properties?.action_link || redirectTo;

    // Envoyer l'email
    const html = welcomeHtml({
      email,
      nomCentre: centre.nom,
      licenseKey: centre.license_key,
      plan: centre.plan,
      magicLink,
      licenseType: centre.license_type
    });
    const form = new FormData();
    form.append('from', MAILGUN_FROM);
    form.append('to', email);
    form.append('subject', `Bienvenue chez MIBsoft — Votre accès ${(centre.plan || '').toUpperCase()}`);
    form.append('html', html);

    const mg = await fetch(`https://${MAILGUN_HOST}/v3/${MAILGUN_DOMAIN}/messages`, {
      method: 'POST',
      headers: { 'Authorization': `Basic ${btoa(`api:${MAILGUN_API_KEY}`)}` },
      body: form
    });
    const mgTxt = await mg.text();
    if (!mg.ok) return json({ error: 'mailgun_failed', status: mg.status, body: mgTxt.slice(0,500) }, 502);

    return json({ ok: true, sent_to: email, magic_link_generated: !!linkData?.properties?.action_link, mailgun: tryParse(mgTxt) });
  } catch (e) {
    console.error(e);
    return json({ error: 'server_error', message: String(e?.message || e) }, 500);
  }
});

function welcomeHtml({ email, nomCentre, licenseKey, plan, magicLink, licenseType }: any) {
  return `
    <div style="text-align:center;margin:0 0 24px;"><img src="https://mibsoft.fr/logo/logo-web-transparent.png" alt="MIBsoft" width="160" style="display:inline-block;max-width:160px;height:auto;border:0;"></div>
    <h2 style="font-family:Georgia,serif;color:#1A2842;">Bienvenue chez MIBsoft</h2>
    <p>Bonjour,</p>
    <p>Votre paiement pour le plan <strong>${(plan || '').toUpperCase()}</strong> a été validé. ${licenseType === 'formateur' ? 'Votre compte formateur indépendant' : `Votre centre <strong>${esc(nomCentre)}</strong>`} est maintenant activé.</p>
    <h3>Vos identifiants</h3>
    <ul>
      <li>Email : <code>${esc(email)}</code></li>
      <li>Clé de licence : <code style="background:#f6f1e7;padding:4px 8px;border-radius:4px;font-size:1.1em;font-weight:700;">${esc(licenseKey)}</code></li>
    </ul>
    <h3>Première connexion</h3>
    <p style="text-align:center;margin:30px 0;">
      <a href="${esc(magicLink)}" style="background:#C8102E;color:#fff;padding:12px 30px;text-decoration:none;border-radius:8px;font-weight:700;display:inline-block;">Définir mon mot de passe →</a>
    </p>
    <p style="font-size:.85em;color:#666;">Si le bouton ne fonctionne pas, copiez ce lien :<br><code style="font-size:.75em;">${esc(magicLink)}</code></p>
    <hr><p style="font-size:.85em;color:#666;">MIBsoft — Formation SSIAP</p>`;
}
function esc(s: string) { return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function tryParse(t: string) { try { return JSON.parse(t); } catch { return t; } }
function json(o: unknown, s = 200) { return new Response(JSON.stringify(o, null, 2), { status: s, headers: { 'Content-Type': 'application/json', ...CORS } }); }
