-- Permettre au formateur connecté (auth user synthétique) de lire sa propre
-- fiche `formateurs` et son centre `centers`. Sans ces policies, le SELECT
-- post-login échoue car les policies existantes filtrent par `jwt_center_id()`
-- qui n'est défini que pour les comptes "centre".

drop policy if exists "auth_select_own_formateur" on public.formateurs;
create policy "auth_select_own_formateur"
on public.formateurs
for select
to authenticated
using (auth_user_id = auth.uid());

drop policy if exists "auth_select_own_center_via_formateur" on public.centers;
create policy "auth_select_own_center_via_formateur"
on public.centers
for select
to authenticated
using (
  id in (select center_id from public.formateurs where auth_user_id = auth.uid())
);
