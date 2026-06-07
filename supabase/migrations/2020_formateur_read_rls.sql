-- Permettre au formateur connecté de lire les données nécessaires à l'usage de
-- `formateur.html` : ses sessions, leurs participants, et les stagiaires de
-- ses centres. Les policies existantes filtrent par `jwt_center_id()` réservé
-- aux comptes centre — sans ces ajouts le formateur voit des écrans vides.
--
-- Le principe : un formateur a accès aux données des centres listés dans ses
-- lignes `formateurs` (1 ligne par centre où il intervient).

-- ── sessions_formation : SELECT (toutes les sessions de ses centres) ──
drop policy if exists "auth_select_formateur_sessions" on public.sessions_formation;
create policy "auth_select_formateur_sessions"
on public.sessions_formation
for select
to authenticated
using (
  center_id in (select center_id from public.formateurs where auth_user_id = auth.uid())
);

-- ── sessions_formation : UPDATE (uniquement celles dont il est le responsable) ──
drop policy if exists "auth_update_formateur_assigned_session" on public.sessions_formation;
create policy "auth_update_formateur_assigned_session"
on public.sessions_formation
for update
to authenticated
using (
  formateur_id in (select id from public.formateurs where auth_user_id = auth.uid())
)
with check (
  formateur_id in (select id from public.formateurs where auth_user_id = auth.uid())
);

-- ── session_participants : SELECT (participants des sessions de ses centres) ──
drop policy if exists "auth_select_formateur_session_participants" on public.session_participants;
create policy "auth_select_formateur_session_participants"
on public.session_participants
for select
to authenticated
using (
  session_id in (
    select id from public.sessions_formation
    where center_id in (select center_id from public.formateurs where auth_user_id = auth.uid())
  )
);

-- ── stagiaires : SELECT (les stagiaires de ses centres, pour les listes/jointures) ──
drop policy if exists "auth_select_formateur_stagiaires" on public.stagiaires;
create policy "auth_select_formateur_stagiaires"
on public.stagiaires
for select
to authenticated
using (
  center_id in (select center_id from public.formateurs where auth_user_id = auth.uid())
);
