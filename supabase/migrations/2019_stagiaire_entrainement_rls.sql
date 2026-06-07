-- Le stagiaire connecté (auth user synthétique) doit pouvoir lire et écrire
-- SES PROPRES sessions d'entraînement et leurs réponses. La policy existante
-- `auth_all_entrainement_sessions` filtre par `jwt_center_id()` — réservé aux
-- comptes centre, le stagiaire n'a pas ce claim. Sans ces policies, l'insert
-- du quiz et la lecture de l'historique échouent silencieusement.
--
-- Les policies sont permissives (s'ajoutent en OR) : le centre garde son
-- accès complet via la policy existante.

drop policy if exists "auth_select_own_entrainement_session" on public.entrainement_sessions;
create policy "auth_select_own_entrainement_session"
on public.entrainement_sessions
for select
to authenticated
using (
  stagiaire_id in (select id from public.stagiaires where auth_user_id = auth.uid())
);

drop policy if exists "auth_insert_own_entrainement_session" on public.entrainement_sessions;
create policy "auth_insert_own_entrainement_session"
on public.entrainement_sessions
for insert
to authenticated
with check (
  stagiaire_id in (select id from public.stagiaires where auth_user_id = auth.uid())
);

drop policy if exists "auth_update_own_entrainement_session" on public.entrainement_sessions;
create policy "auth_update_own_entrainement_session"
on public.entrainement_sessions
for update
to authenticated
using (
  stagiaire_id in (select id from public.stagiaires where auth_user_id = auth.uid())
)
with check (
  stagiaire_id in (select id from public.stagiaires where auth_user_id = auth.uid())
);

-- entrainement_reponses : même logique mais via session_id.
drop policy if exists "auth_select_own_entrainement_reponse" on public.entrainement_reponses;
create policy "auth_select_own_entrainement_reponse"
on public.entrainement_reponses
for select
to authenticated
using (
  session_id in (
    select es.id
    from public.entrainement_sessions es
    join public.stagiaires s on s.id = es.stagiaire_id
    where s.auth_user_id = auth.uid()
  )
);

drop policy if exists "auth_insert_own_entrainement_reponse" on public.entrainement_reponses;
create policy "auth_insert_own_entrainement_reponse"
on public.entrainement_reponses
for insert
to authenticated
with check (
  session_id in (
    select es.id
    from public.entrainement_sessions es
    join public.stagiaires s on s.id = es.stagiaire_id
    where s.auth_user_id = auth.uid()
  )
);
