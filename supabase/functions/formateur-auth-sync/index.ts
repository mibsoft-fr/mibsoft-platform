// Edge function `formateur-auth-sync` — crée/synchronise les auth users Supabase
// pour les formateurs.
//
// Le login formateur passe par `supabase.auth.signInWithPassword(email, pin)`.
// Comme l'email "réel" du formateur peut être absent ou entrer en collision
// avec celui d'un centre, on utilise un email synthétique propre par formateur :
//     formateur-<formateur_id>@formateurs.mib-prevention.fr
//
// Body (POST JSON) :
//   { formateur_id: uuid? , all: boolean?, new_pin: string? }
//   - formateur_id seul → synchronise UN formateur (crée son auth user si manquant,
//     met à jour le password au pin_clair courant)
//   - all: true        → boucle sur tous les formateurs actifs sans auth_user_id
//   - new_pin          → si fourni, écrase le password Supabase avec cette valeur
//
// Sécurité : la fonction utilise SERVICE_ROLE — exposer uniquement aux flux
// internes (création de formateur, reset PIN), pas aux clients non authentifiés.

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

  const body = await req.json().catch(() => ({} as any));
  const formateurId: string | null = body?.formateur_id || null;
  const newPin: string | null = body?.new_pin || null;
  const allMode: boolean = body?.all === true || (!formateurId && !newPin);

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE);

  let q = admin.from('formateurs')
    .select('id, prenom, nom, pin_clair, auth_user_id, actif')
    .eq('actif', true);
  if (formateurId) {
    q = q.eq('id', formateurId);
  } else if (allMode) {
    q = q.is('auth_user_id', null);
  }

  const { data: list, error } = await q;
  if (error) return json({ ok: false, error: error.message }, 500);

  const results: any[] = [];
  for (const f of (list || []) as any[]) {
    const password = newPin || f.pin_clair;
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
    } else if (newPin) {
      const { error: pErr } = await admin.auth.admin.updateUserById(authUserId, { password });
      if (pErr) {
        results.push({ id: f.id, ok: false, reason: pErr.message });
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
