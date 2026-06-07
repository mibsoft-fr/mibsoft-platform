-- Permettre au stagiaire connecté (auth user synthétique) de lire sa propre
-- fiche `stagiaires` et son centre `centers`. Même logique que la migration
-- 2014 pour les formateurs.

drop policy if exists "auth_select_own_stagiaire" on public.stagiaires;
create policy "auth_select_own_stagiaire"
on public.stagiaires
for select
to authenticated
using (auth_user_id = auth.uid());

drop policy if exists "auth_select_own_center_via_stagiaire" on public.centers;
create policy "auth_select_own_center_via_stagiaire"
on public.centers
for select
to authenticated
using (
  id in (select center_id from public.stagiaires where auth_user_id = auth.uid())
);
