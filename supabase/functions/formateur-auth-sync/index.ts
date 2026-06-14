// Edge function `formateur-auth-sync` — crée/synchronise les auth users Supabase
// pour les formateurs.
//
// Le login formateur passe par `supabase.auth.signInWithPassword(email, pin)`.
// Comme l'email "réel" du formateur peut être absent ou entrer en collision
// avec celui d'un centre, on utilise un email synthétique propre par formateur :
//     formateur-<formateur_id>@formateurs.mib-prevention.fr
//
// Body (POST JSON) : { formateur_id: uuid }
//   → synchronise UN formateur : crée son auth user si manquant et fixe son password au pin_clair
//     courant EN BASE. Le mot de passe n'est jamais fourni par l'appelant (capability retirée), et il
//     n'y a plus de mode « all ».
//
// Sécurité : utilise SERVICE_ROLE. Le handler EXIGE un appelant authentifié (centre connecté) ou
// interne (clé service_role) — sinon 401. Empêche l'abus via la clé anon publique.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS'
};

function syntheticEmail(formateurId: string) {
  return `formateur-${formateurId}@formateurs.mib-prevention.fr`;
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE);

  // SÉCURITÉ : n'autoriser QUE des appelants AUTHENTIFIÉS (centre connecté). Sans ce contrôle, la
  // clé anon publique suffisait à invoquer cette fonction service_role et à toucher n'importe quel
  // compte. getUser() valide le JWT et échoue pour un token anon (sans utilisateur).
  const authHeader = req.headers.get('Authorization') || '';
  const jwt = authHeader.replace(/^Bearer\s+/i, '');
  let authorized = false;
  if (jwt && jwt === SERVICE_ROLE) authorized = true;                       // appels internes (service_role)
  else if (jwt) authorized = !!(await admin.auth.getUser(jwt)).data.user;   // utilisateur connecté (centre)
  if (!authorized) return json({ ok: false, error: 'UNAUTHENTICATED' }, 401);

  const body = await req.json().catch(() => ({} as any));
  const formateurId: string | null = body?.formateur_id || null;
  // On exige un id précis et le mot de passe est TOUJOURS le PIN courant en base (pin_clair) : on
  // n'accepte plus de mot de passe fourni par l'appelant ni de mode « all » (évite la réinitialisation
  // du PIN d'un compte tiers à une valeur choisie → prise de contrôle).
  if (!formateurId) return json({ ok: false, error: 'formateur_id requis' }, 400);

  const q = admin.from('formateurs')
    .select('id, prenom, nom, pin_clair, auth_user_id, actif')
    .eq('actif', true)
    .eq('id', formateurId);

  const { data: list, error } = await q;
  if (error) return json({ ok: false, error: error.message }, 500);

  const results: any[] = [];
  for (const f of (list || []) as any[]) {
    const password = f.pin_clair;
    if (!password) {
      results.push({ id: f.id, ok: false, reason: 'no_pin' });
      continue;
    }
    const email = syntheticEmail(f.id);
    let authUserId: string | null = f.auth_user_id;

    if (!authUserId) {
      const { data: created, error: cErr } = await admin.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: { kind: 'formateur', formateur_id: f.id, prenom: f.prenom, nom: f.nom }
      });
      if (cErr || !created?.user) {
        // Idempotence : si l'email synthétique existe déjà (re-sync), on récupère l'ID.
        const { data: existing } = await admin.rpc('auth_user_id_by_email', { p_email: email });
        if (existing) {
          authUserId = existing as string;
          await admin.auth.admin.updateUserById(authUserId, { password });
        } else {
          results.push({ id: f.id, ok: false, reason: cErr?.message || 'create_failed' });
          continue;
        }
      } else {
        authUserId = created.user.id;
      }
      const { error: upErr } = await admin
        .from('formateurs')
        .update({ auth_user_id: authUserId })
        .eq('id', f.id);
      if (upErr) {
        results.push({ id: f.id, ok: false, reason: upErr.message });
        continue;
      }
    }

    results.push({ id: f.id, ok: true, auth_user_id: authUserId, email });
  }

  return json({ ok: true, count: results.length, results });
});

function json(obj: unknown, status = 200) {
  return new Response(JSON.stringify(obj), { status, headers: { ...cors, 'Content-Type': 'application/json' } });
}
