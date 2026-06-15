-- C2 (phase B) : le login Patrol comparait le PIN DANS LE NAVIGATEUR a partir de pin_hash/pin_clair
-- telecharges en clair (RPC get_patrol_agents_from_formateurs + table patrol_data ouverte en anon).
-- On bascule la comparaison COTE SERVEUR : plus aucun PIN (clair ni hash) n'est envoye au client.
-- (Applique en prod via apply_migration le 2026-06-15.)
-- NB residuel : la table patrol_data reste lisible en anon (policy patrol_access ALL using(true)),
-- son JSON agents contient encore pinHash/pinClair -> traite dans le chantier "patrol_data verrouille".

create or replace function public.patrol_agents_list(p_center_id uuid, p_session_id uuid)
returns table(id text, nom text, prenom text, qualification text, type text, entreprise text)
language plpgsql security definer set search_path to 'public' as $fn$
begin
  if exists (
    select 1 from public.patrol_data pd,
         jsonb_array_elements(coalesce(pd.agents::jsonb,'[]'::jsonb)) a
    where pd.center_id = p_center_id
      and (case when p_session_id is null then pd.session_id is null else pd.session_id = p_session_id end)
      and coalesce((a->>'actif')::boolean, true)
  ) then
    return query
      select a->>'id', a->>'nom', a->>'prenom',
             coalesce(a->>'qualification','Agent'), coalesce(a->>'type','agent'), a->>'entreprise'
      from public.patrol_data pd,
           jsonb_array_elements(coalesce(pd.agents::jsonb,'[]'::jsonb)) a
      where pd.center_id = p_center_id
        and (case when p_session_id is null then pd.session_id is null else pd.session_id = p_session_id end)
        and coalesce((a->>'actif')::boolean, true);
  else
    return query
      select f.id::text, f.nom, f.prenom, 'SSIAP 2'::text, 'formateur'::text, c.nom
      from public.formateurs f
      left join public.centers c on c.id = f.center_id
      where f.center_id = p_center_id and f.actif = true
      order by f.nom;
  end if;
end $fn$;

create or replace function public.patrol_resolve(
  p_center_id uuid, p_session_id uuid, p_agent_id text, p_pin text)
returns table(ok boolean, locked boolean, nom text, prenom text, qualification text, type text, entreprise text)
language plpgsql security definer set search_path to 'public','extensions','auth' as $fn$
declare
  v_hash text; v_rec jsonb; v_ok boolean := false;
  r_nom text; r_prenom text; r_qual text := 'Agent'; r_type text := 'agent'; r_ent text;
begin
  if p_agent_id is null or p_pin !~ '^[0-9]{3,8}$' then
    return query select false, false, null::text, null::text, null::text, null::text, null::text; return;
  end if;
  if public._login_throttle_blocked() then
    return query select false, true, null::text, null::text, null::text, null::text, null::text; return;
  end if;
  v_hash := encode(digest(p_pin, 'sha256'), 'hex');

  select a into v_rec
  from public.patrol_data pd,
       jsonb_array_elements(coalesce(pd.agents::jsonb,'[]'::jsonb)) a
  where pd.center_id = p_center_id
    and (case when p_session_id is null then pd.session_id is null else pd.session_id = p_session_id end)
    and (a->>'id') = p_agent_id
    and coalesce((a->>'actif')::boolean, true)
  limit 1;

  if v_rec is not null then
    v_ok := (v_rec->>'pinHash' = v_hash)
            or (coalesce(v_rec->>'pinClair','') <> '' and v_rec->>'pinClair' = p_pin);
    r_nom := v_rec->>'nom'; r_prenom := v_rec->>'prenom';
    r_qual := coalesce(v_rec->>'qualification','Agent');
    r_type := coalesce(v_rec->>'type','agent');
    r_ent  := v_rec->>'entreprise';
  else
    select f.nom, f.prenom, (f.pin_hash = v_hash), c.nom
      into r_nom, r_prenom, v_ok, r_ent
      from public.formateurs f
      left join public.centers c on c.id = f.center_id
     where f.id::text = p_agent_id and f.center_id = p_center_id and f.actif = true
     limit 1;
    r_qual := 'SSIAP 2'; r_type := 'formateur';
    if v_ok is null then v_ok := false; end if;
  end if;

  perform public._login_throttle_record(v_ok);
  return query select v_ok, false, r_nom, r_prenom, r_qual, r_type, r_ent;
end $fn$;

create or replace function public.get_patrol_agents_from_formateurs(p_center_id uuid)
returns table(id uuid, nom text, prenom text, pin_hash text, pin_clair text, email text, telephone text)
language sql security definer set search_path to 'public' as $fn$
  select f.id, f.nom, f.prenom, null::text, null::text, f.email, f.telephone
    from public.formateurs f
   where f.center_id = p_center_id and f.actif = true
   order by f.nom;
$fn$;

grant execute on function public.patrol_agents_list(uuid, uuid) to anon, authenticated;
grant execute on function public.patrol_resolve(uuid, uuid, text, text) to anon, authenticated;
