-- Ecriture securisee : un centre authentifie ne peut creer/modifier que SON etablissement.
-- (Meme mecanisme que patrol_data : jwt_center_id().) L'editeur cote SSI/centre est authentifie.
drop policy if exists patrol_etab_write_center on public.patrol_etablissements;
create policy patrol_etab_write_center on public.patrol_etablissements
  for all to authenticated
  using (center_id = jwt_center_id())
  with check (center_id = jwt_center_id());
grant insert, update, delete on public.patrol_etablissements to authenticated;

-- Index unique sur (center_id, plan_key) requis par l'upsert PostgREST (onConflict).
create unique index if not exists patrol_etab_cp_uidx
  on public.patrol_etablissements (center_id, plan_key);
