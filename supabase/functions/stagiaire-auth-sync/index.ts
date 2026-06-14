// Edge function `stagiaire-auth-sync` — équivalent stagiaire de
// `formateur-auth-sync` : crée/synchronise l'auth user Supabase pour les
// stagiaires afin que le login PIN fonctionne via `signInWithPassword`.
//
// Email synthétique : `stagiaire-<id>@stagiaires.mib-prevention.fr`
// Mot de passe      : PIN courant du stagiaire EN BASE (pin_clair). Jamais fourni par l'appelant.
//
// Body (POST JSON) : { stagiaire_id: uuid }
// Sécurité : SERVICE_ROLE. Handler exige un appelant authentifié (centre) ou interne (service_role).

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS'
};

function syntheticEmail(stagiaireId: string) {
  return `stagiaire-${stagiaireId}@stagiaires.mib-prevention.fr`;
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE);

  // SÉCURITÉ : n'autoriser QUE des appelants AUTHENTIFIÉS (centre connecté). Sans ce contrôle, la
  // clé anon publique suffisait à invoquer cette fonction service_role. getUser() valide le JWT et
  // échoue pour un token anon (sans utilisateur).
  const authHeader = req.headers.get('Authorization') || '';
  const jwt = authHeader.replace(/^Bearer\s+/i, '');
  let authorized = false;
  if (jwt && jwt === SERVICE_ROLE) authorized = true;                       // appels internes (service_role)
  else if (jwt) authorized = !!(await admin.auth.getUser(jwt)).data.user;   // utilisateur connecté (centre)
  if (!authorized) return json({ ok: false, error: 'UNAUTHENTICATED' }, 401);

  const body = await req.json().catch(() => ({} as any));
  const stagiaireId: string | null = body?.stagiaire_id || null;
  // id précis requis + mot de passe TOUJOURS = PIN courant en base (jamais fourni par l'appelant ;
  // plus de mode « all ») → empêche la réinitialisation du PIN d'un tiers à une valeur choisie.
  if (!stagiaireId) return json({ ok: false, error: 'stagiaire_id requis' }, 400);

  const q = admin.from('stagiaires')
    .select('id, prenom, nom, pin_clair, auth_user_id, actif')
    .eq('actif', true)
    .eq('id', stagiaireId);

  const { data: list, error } = await q;
  if (error) return json({ ok: false, error: error.message }, 500);

  const results: any[] = [];
  for (const s of (list || []) as any[]) {
    const password = s.pin_clair;
    if (!password) {
      results.push({ id: s.id, ok: false, reason: 'no_pin' });
      continue;
    }
    const email = syntheticEmail(s.id);
    let authUserId: string | null = s.auth_user_id;

    if (!authUserId) {
      const { data: created, error: cErr } = await admin.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: { kind: 'stagiaire', stagiaire_id: s.id, prenom: s.prenom, nom: s.nom }
      });
      if (cErr || !created?.user) {
        const { data: existing } = await admin.rpc('auth_user_id_by_email', { p_email: email });
        if (existing) {
          authUserId = existing as string;
          await admin.auth.admin.updateUserById(authUserId, { password });
        } else {
          results.push({ id: s.id, ok: false, reason: cErr?.message || 'create_failed' });
          continue;
        }
      } else {
        authUserId = created.user.id;
      }
      const { error: upErr } = await admin
        .from('stagiaires')
        .update({ auth_user_id: authUserId })
        .eq('id', s.id);
      if (upErr) {
        results.push({ id: s.id, ok: false, reason: upErr.message });
        continue;
      }
    }

    results.push({ id: s.id, ok: true, auth_user_id: authUserId, email });
  }

  return json({ ok: true, count: results.length, results });
});

function json(obj: unknown, status = 200) {
  return new Response(JSON.stringify(obj), { status, headers: { ...cors, 'Content-Type': 'application/json' } });
}
