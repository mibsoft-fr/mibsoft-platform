import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!;
const MAILGUN_API_KEY = Deno.env.get('MAILGUN_API_KEY') || '';
const MAILGUN_DOMAIN = Deno.env.get('MAILGUN_DOMAIN') || 'mib-prevention.fr';
const MAILGUN_HOST = Deno.env.get('MAILGUN_HOST') || 'api.eu.mailgun.net';
const MAILGUN_FROM = Deno.env.get('MAILGUN_FROM') || `MIBsoft <noreply@${MAILGUN_DOMAIN}>`;
const APP_URL = Deno.env.get('APP_URL') || 'https://app.mib-prevention.fr';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS'
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) return json({ error: 'missing_authorization' }, 401);

    const userClient = createClient(SUPABASE_URL, ANON_KEY, {
      global: { headers: { Authorization: authHeader } }
    });
    const { data: { user }, error: uerr } = await userClient.auth.getUser();
    if (uerr || !user) return json({ error: 'invalid_token' }, 401);

    const admin = createClient(SUPABASE_URL, SERVICE_ROLE);
    const { data: sa } = await admin.from('super_admins').select('auth_user_id').eq('auth_user_id', user.id).maybeSingle();
    if (!sa) return json({ error: 'forbidden_not_super_admin' }, 403);

    const body = await req.json();
    const { email, nom, plan, license_key, license_expires_at, license_status, license_type, billing_cycle,
            max_formateurs, max_stagiaires, adresse, ville, code_postal, telephone } = body;

    // Mode d'activation : invitation magique (par défaut) ou mot de passe manuel (legacy)
    const sendMagicLink = body.send_magic_link !== false; // défaut true
    const passwordProvided = typeof body.password === 'string' && body.password.length > 0;
    const paymentMethod = body.payment_method || (sendMagicLink ? 'virement' : 'manuel'); // pour traçabilité

    if (!email || !nom || !license_key) return json({ error: 'missing_fields' }, 400);
    if (!sendMagicLink && !passwordProvided) return json({ error: 'password_required_when_not_magic_link' }, 400);
    if (passwordProvided && body.password.length < 8) return json({ error: 'password_too_short' }, 400);

    const emailLow = String(email).trim().toLowerCase();

    const { data: existing } = await admin.from('centers').select('id').eq('email', emailLow).maybeSingle();
    if (existing) return json({ error: 'email_already_used' }, 409);

    // Générer un mot de passe random pour le mode invitation (le centre le redéfinira via le lien magique)
    const finalPassword = passwordProvided ? body.password : crypto.randomUUID() + crypto.randomUUID();

    const { data: created, error: cerr } = await admin.auth.admin.createUser({
      email: emailLow,
      password: finalPassword,
      email_confirm: true,
      user_metadata: { nom_centre: nom, created_via: paymentMethod }
    });
    if (cerr || !created.user) return json({ error: 'auth_create_failed', detail: cerr?.message }, 500);

    const newAuthId = created.user.id;

    // Rôle profile selon license_type
    const profileRole = license_type === 'independant' ? 'formateur' : 'centre';

    const centreRow: any = {
      auth_user_id: newAuthId,
      email: emailLow,
      nom,
      license_key,
      plan: plan || 'starter',
      license_status: license_status || 'active',
      license_type: license_type || 'centre',
      billing_cycle: billing_cycle || 'annuel',
      license_expires_at: license_expires_at || null,
      max_formateurs: max_formateurs ?? 5,
      max_stagiaires: max_stagiaires ?? 50,
      password_set: !sendMagicLink, // si magic link → false (le centre devra définir son mdp)
      adresse: adresse || null,
      ville: ville || null,
      code_postal: code_postal || null,
      telephone: telephone || null
    };
    const { data: centre, error: ierr } = await admin.from('centers').insert(centreRow).select('id').single();
    if (ierr) {
      await admin.auth.admin.deleteUser(newAuthId);
      return json({ error: 'centre_insert_failed', detail: ierr.message }, 500);
    }

    const { error: perr } = await admin.from('profiles').upsert({
      user_id: newAuthId,
      role: profileRole,
      center_id: centre.id,
      linked_id: centre.id
    });
    if (perr) console.error('profile insert failed', perr);

    // Mode invitation magique : générer le lien + envoyer email
    let emailSent = false;
    let emailError: string | null = null;
    if (sendMagicLink) {
      try {
        const redirectTo = `${APP_URL}/${profileRole === 'formateur' ? 'login-formateur' : 'login-centre'}.html`;
        const { data: linkData, error: lerr } = await admin.auth.admin.generateLink({
          type: 'recovery',
          email: emailLow,
          options: { redirectTo }
        });
        if (lerr) throw lerr;
        const magicLink = linkData?.properties?.action_link || redirectTo;

        if (!MAILGUN_API_KEY) {
          emailError = 'mailgun_api_key_missing';
        } else {
          const html = welcomeHtml({
            email: emailLow,
            nomCentre: nom,
            licenseKey: license_key,
            plan: plan || 'starter',
            magicLink,
            licenseType: license_type || 'centre',
            paymentMethod
          });
          const form = new FormData();
          form.append('from', MAILGUN_FROM);
          form.append('to', emailLow);
          form.append('subject', `Bienvenue chez MIBsoft — Votre accès ${(plan || 'STARTER').toUpperCase()}`);
          form.append('html', html);
          const mg = await fetch(`https://${MAILGUN_HOST}/v3/${MAILGUN_DOMAIN}/messages`, {
            method: 'POST',
            headers: { 'Authorization': `Basic ${btoa(`api:${MAILGUN_API_KEY}`)}` },
            body: form
          });
          if (!mg.ok) {
            emailError = `mailgun_${mg.status}: ${(await mg.text()).slice(0,200)}`;
          } else {
            emailSent = true;
          }
        }
      } catch (e) {
        emailError = String(e?.message || e);
      }
    }

    return json({
      ok: true,
      centre_id: centre.id,
      auth_user_id: newAuthId,
      mode: sendMagicLink ? 'magic_link' : 'manual_password',
      email_sent: emailSent,
      email_error: emailError
    });
  } catch (e) {
    return json({ error: 'unexpected', detail: String(e?.message || e) }, 500);
  }
});

function welcomeHtml({ email, nomCentre, licenseKey, plan, magicLink, licenseType, paymentMethod }: any) {
  const paymentLabel = paymentMethod === 'virement' ? 'Suite à votre paiement par virement,' : 'Suite à votre inscription,';
  return `
    <div style="text-align:center;margin:0 0 24px;"><img src="https://mibsoft.fr/logo/logo-web-transparent.png" alt="MIBsoft" width="160" style="display:inline-block;max-width:160px;height:auto;border:0;"></div>
    <h2 style="font-family:Georgia,serif;color:#1A2842;">Bienvenue chez MIBsoft</h2>
    <p>Bonjour,</p>
    <p>${paymentLabel} ${licenseType === 'independant' ? 'votre compte formateur indépendant' : `votre centre <strong>${esc(nomCentre)}</strong>`} est maintenant activé sur le plan <strong>${esc((plan||'').toUpperCase())}</strong>.</p>
    <h3>Vos identifiants</h3>
    <ul>
      <li>Email : <code>${esc(email)}</code></li>
      <li>Clé de licence : <code style="background:#f6f1e7;padding:4px 8px;border-radius:4px;font-size:1.1em;font-weight:700;">${esc(licenseKey)}</code></li>
    </ul>
    <h3>Première connexion</h3>
    <p>Cliquez sur le bouton ci-dessous pour définir votre mot de passe et accéder à votre espace.</p>
    <p style="text-align:center;margin:30px 0;">
      <a href="${esc(magicLink)}" style="background:#C8102E;color:#fff;padding:12px 30px;text-decoration:none;border-radius:8px;font-weight:700;display:inline-block;">Définir mon mot de passe →</a>
    </p>
    <p style="font-size:.85em;color:#666;">Si le bouton ne fonctionne pas, copiez ce lien dans votre navigateur :<br><code style="font-size:.75em;">${esc(magicLink)}</code></p>
    <hr style="margin:30px 0;border:none;border-top:1px solid #eee;">
    <p style="font-size:.85em;color:#666;">Une question ? Répondez à cet email.</p>
    <p style="font-size:.85em;color:#666;">MIBsoft — Formation SSIAP</p>`;
}
function esc(s: string) { return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function json(obj: unknown, status = 200) {
  return new Response(JSON.stringify(obj), { status, headers: { ...cors, 'Content-Type': 'application/json' } });
}
