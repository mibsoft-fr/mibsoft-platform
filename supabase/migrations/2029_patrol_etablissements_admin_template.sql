-- Ecriture du MODELE d'etablissement (center_id NULL) reservee au super-admin.
-- Symetrique de `plantypes_write_admin` sur ssi_plan_types : l'admin construit la structure
-- modele (locaux + materiels) d'un plan partage, dont tous les centres heritent ensuite
-- (patrol-admin "Importer la structure" prend la version du centre sinon le template).
drop policy if exists patrol_etab_write_admin on public.patrol_etablissements;
create policy patrol_etab_write_admin on public.patrol_etablissements
  for all to authenticated
  using (center_id is null and jwt_is_super_admin())
  with check (center_id is null and jwt_is_super_admin());
