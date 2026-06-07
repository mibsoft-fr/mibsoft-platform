import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const MAILGUN_API_KEY = Deno.env.get('MAILGUN_API_KEY') || '';
const MAILGUN_DOMAIN = Deno.env.get('MAILGUN_DOMAIN') || 'mib-prevention.fr';
const MAILGUN_HOST = Deno.env.get('MAILGUN_HOST') || 'api.eu.mailgun.net';
const MAILGUN_FROM = Deno.env.get('MAILGUN_FROM') || `MIB Prévention <noreply@${MAILGUN_DOMAIN}>`;

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS'
};

// Réponse uniforme pour éviter l'énumération d'emails : on ne dit jamais si
// l'email existe ou pas dans la base.
const RESPONSE_OK = {
  ok: true,
  message: "Si cet email correspond à un formateur, un nouveau PIN vient d'être envoyé."
};

async function hashSha256Hex(s: string): Promise<string> {
  const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(s));
  return [...new Uint8Array(buf)].map(b => b.toString(16).padStart(2, '0')).join('');
}

function generatePin(): string {
  return String(Math.floor(100000 + Math.random() * 900000));
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });

  let body: any = {};
  try { body = await req.json(); } catch { /* empty body OK, on retournera ok */ }
  const email = String(body?.email || '').trim().toLowerCase();

  if (!email || !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
    return json(RESPONSE_OK);
  }

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE);

  const { data: formateurs, error } = await admin
    .from('formateurs')
    .select('id, prenom, nom, niveau, center_id, auth_user_id, centers ( nom )')
    .eq('email', email)
    .eq('actif', true);

  if (error || !formateurs || formateurs.length === 0) {
    return json(RESPONSE_OK);
  }

  // Régénère un PIN unique par centre pour chaque formateur trouvé.
  const updated: { prenom: string, nom: string, niveau: string | null, center_nom: string, pin: string }[] = [];
  for (const f of formateurs as any[]) {
    let newPin = '';
    let newHash = '';
    for (let attempt = 0; attempt < 20; attempt++) {
      const candidate = generatePin();
      const candidateHash = await hashSha256Hex(candidate);
      const { data: existing } = await admin
        .from('formateurs')
        .select('id')
        .eq('center_id', f.center_id)
        .eq('pin_hash', candidateHash)
        .eq('actif', true)
        .neq('id', f.id);
      if (!existing || existing.length === 0) {
        newPin = candidate;
        newHash = candidateHash;
        break;
      }
    }
    if (!newPin) continue;

    const { error: upErr } = await admin
      .from('formateurs')
      .update({
        pin_hash: newHash,
        pin_clair: newPin,
        failed_attempts: 0,
        locked_until: null
      })
      .eq('id', f.id);
    if (upErr) continue;

    // Synchronise le password Supabase auth (sinon le nouveau PIN ne permet pas de se connecter).
    // Si pas d'auth_user_id (formateur jamais bootstrappé), on crée l'auth user via formateur-auth-sync.
    if (f.auth_user_id) {
      await admin.auth.admin.updateUserById(f.auth_user_id, { password: newPin });
    } else {
      await admin.functions.invoke('formateur-auth-sync', {
        body: { formateur_id: f.id, new_pin: newPin }
      });
    }

    updated.push({
      prenom: f.prenom,
      nom: f.nom,
      niveau: f.niveau,
      center_nom: f.centers?.nom || '—',
      pin: newPin
    });
  }

  if (updated.length === 0) return json(RESPONSE_OK);

  // Envoi du mail (best-effort, on retourne ok même si l'envoi échoue).
  if (MAILGUN_API_KEY) {
    try {
      const subject = updated.length > 1
        ? `[MIB] Vos nouveaux codes PIN (${updated.length} centres)`
        : `[MIB] Votre nouveau code PIN`;
      const html = buildHtml(updated);
      const form = new FormData();
      form.append('from', MAILGUN_FROM);
      form.append('to', email);
      form.append('subject', subject);
      form.append('html', html);
      await fetch(`https://${MAILGUN_HOST}/v3/${MAILGUN_DOMAIN}/messages`, {
        method: 'POST',
        headers: { 'Authorization': `Basic ${btoa(`api:${MAILGUN_API_KEY}`)}` },
        body: form
      });
    } catch (_e) {
      // ignore : on ne donne pas de détail au client
    }
  }

  return json(RESPONSE_OK);
});

function buildHtml(items: { prenom: string, nom: string, niveau: string | null, center_nom: string, pin: string }[]) {
  const lines = items.map(i => {
    const niv = i.niveau ? ` <span style="color:#6b7280;">(${escapeHtml(i.niveau)})</span>` : '';
    return `<li style="margin: 10px 0;">
      <div><strong>${escapeHtml(i.center_nom)}</strong>${niv}</div>
      <div style="margin-top:4px;">Nouveau PIN : <span style="font-family:monospace;font-size:1.4rem;letter-spacing:.2em;font-weight:800;color:#059669;">${escapeHtml(i.pin)}</span></div>
    </li>`;
  }).join('');
  const intro = items.length > 1
    ? `<p>Vous êtes inscrit(e) dans plusieurs centres. Voici un nouveau PIN pour chacun :</p>`
    : `<p>Voici votre nouveau code PIN pour vous connecter à votre espace formateur :</p>`;
  return `<div style="font-family:Arial,sans-serif;max-width:520px;line-height:1.5;">
    <h2 style="color:#065f46;margin-top:0;">Réinitialisation de votre code PIN</h2>
    <p>Bonjour ${escapeHtml(items[0].prenom)} ${escapeHtml(items[0].nom)},</p>
    ${intro}
    <ul style="list-style:none;padding-left:0;background:#f0fdf4;border-radius:8px;padding:14px 18px;border:1px solid #bbf7d0;">${lines}</ul>
    <p style="color:#b91c1c;"><strong>⚠️ Vos anciens codes PIN ne fonctionnent plus.</strong></p>
    <p style="color:#6b7280;font-size:.85rem;">Si vous n'êtes pas à l'origine de cette demande, contactez votre responsable de centre — vos anciens PIN ont été invalidés.</p>
  </div>`;
}

function json(obj: unknown, status = 200) {
  return new Response(JSON.stringify(obj), { status, headers: { ...cors, 'Content-Type': 'application/json' } });
}

function escapeHtml(s: any) {
  return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}
