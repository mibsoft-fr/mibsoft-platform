-- ============================================================
-- RLS centers : lecture de SA propre fiche via auth_user_id
-- ============================================================
-- Les policies SELECT existantes n'autorisaient l'utilisateur authentifié
-- qu'au travers de jwt_center_id() (centre), de formateurs ou de stagiaires.
-- Un APPRENANT (license_type='apprenant') n'entrait dans aucun cas → sa fiche
-- centers était illisible après connexion ('Compte introuvable').
--
-- On ajoute une policy générique : chacun peut lire SA ligne via auth_user_id.
-- (login-apprenant.html / apprenant.html font .eq('auth_user_id', auth.uid()).)

drop policy if exists auth_select_own_center_via_auth_user_id on public.centers;
create policy auth_select_own_center_via_auth_user_id on public.centers
  for select to authenticated
  using (auth_user_id = auth.uid());
