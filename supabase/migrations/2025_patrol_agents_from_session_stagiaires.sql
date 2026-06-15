-- Refonte module Patrol : les "agents" d'une session = les STAGIAIRES rattaches a la session
-- (session_participants -> stagiaires), charges automatiquement. Le login rondier (telephone) liste
-- ces stagiaires et verifie LEUR PIN cote serveur. Fallback formateurs uniquement hors session.
-- (Applique en prod via apply_migration le 2026-06-15. N'affecte que les nouveaux clients/preview ;
--  l'ancien patrol-login.html en prod n'appelle pas ces RPC.)

create or replace function public.patrol_agents_list(p_center_id uuid, p_session_id uuid)
returns table(id text, nom text, prenom text, qualification text, type text, entreprise text)
language plpgsql security definer set search_path to 'public' as $fn$
declare v_center_nom text;
begin
  select c.nom into v_center_nom from public.centers c where c.id = p_center_id;

  if p_session_id is not null then
    return query
      select s.id::text, s.nom, s.prenom,
             case upper(replace(coalesce(s.niveau,''),' ',''))
               when 'SSIAP3' then 'SSIAP 3' when 'SSIAP2' then 'SSIAP 2' else 'SSIAP 1' end,
             'stagiaire'::text, coalesce(v_center_nom,'')
      from public.session_participants sp
      join public.stagiaires s on s.id = sp.stagiaire_id
      where sp.session_id = p_session_id
      union
      select a->>'id', a->>'nom', a->>'prenom',
             coalesce(a->>'qualification','Agent'), coalesce(a->>'type','agent'), a->>'entreprise'
      from public.patrol_data pd,
           jsonb_array_elements(coalesce(pd.agents::jsonb,'[]'::jsonb)) a
      where pd.center_id = p_center_id and pd.session_id = p_session_id
        and coalesce((a->>'actif')::boolean, true)
        and coalesce(a->>'type','') <> 'stagiaire'
        and (a->>'id') not in (
          select s2.id::text from public.session_participants sp2
          join public.stagiaires s2 on s2.id = sp2.stagiaire_id
          where sp2.session_id = p_session_id);
  else
    if exists (select 1 from public.patrol_data pd,
                 jsonb_array_elements(coalesce(pd.agents::jsonb,'[]'::jsonb)) a
               where pd.center_id = p_center_id and pd.session_id is null
                 and coalesce((a->>'actif')::boolean, true)) then
      return query
        select a->>'id', a->>'nom', a->>'prenom',
               coalesce(a->>'qualification','Agent'), coalesce(a->>'type','agent'), a->>'entreprise'
        from public.patrol_data pd,
             jsonb_array_elements(coalesce(pd.agents::jsonb,'[]'::jsonb)) a
        where pd.center_id = p_center_id and pd.session_id is null
          and coalesce((a->>'actif')::boolean, true);
    else
      return query
        select f.id::text, f.nom, f.prenom, 'SSIAP 2'::text, 'formateur'::text, coalesce(v_center_nom,'')
        from public.formateurs f
        where f.center_id = p_center_id and f.actif = true order by f.nom;
    end if;
  end if;
end $fn$;

create or replace function public.patrol_resolve(
  p_center_id uuid, p_session_id uuid, p_agent_id text, p_pin text)
returns table(ok boolean, locked boolean, nom text, prenom text, qualification text, type text, entreprise text)
language plpgsql security definer set search_path to 'public','extensions','auth' as $fn$
declare
  v_hash text; v_rec jsonb; v_ok boolean := false; v_found boolean := false;
  r_nom text; r_prenom text; r_qual text := 'Agent'; r_type text := 'agent'; r_ent text;
  v_center_nom text; v_niveau text; v_ph text; v_pc text;
begin
  if p_agent_id is null or p_pin !~ '^[0-9]{3,8}$' then
    return query select false, false, null::text, null::text, null::text, null::text, null::text; return;
  end if;
  if public._login_throttle_blocked() then
    return query select false, true, null::text, null::text, null::text, null::text, null::text; return;
  end if;
  select c.nom into v_center_nom from public.centers c where c.id = p_center_id;
  v_hash := encode(digest(p_pin, 'sha256'), 'hex');

  if p_session_id is not null then
    select s.nom, s.prenom, s.niveau, s.pin_hash, s.pin_clair
      into r_nom, r_prenom, v_niveau, v_ph, v_pc
      from public.session_participants sp
      join public.stagiaires s on s.id = sp.stagiaire_id
     where sp.session_id = p_session_id and s.id::text = p_agent_id
     limit 1;
    if r_nom is not null then
      v_found := true;
      v_ok := (v_ph = v_hash) or (coalesce(v_pc,'') <> '' and v_pc = p_pin);
      r_qual := case upper(replace(coalesce(v_niveau,''),' ',''))
                  when 'SSIAP3' then 'SSIAP 3' when 'SSIAP2' then 'SSIAP 2' else 'SSIAP 1' end;
      r_type := 'stagiaire'; r_ent := coalesce(v_center_nom,'');
    end if;
  end if;

  if not v_found then
    select a into v_rec
      from public.patrol_data pd, jsonb_array_elements(coalesce(pd.agents::jsonb,'[]'::jsonb)) a
     where pd.center_id = p_center_id
       and (case when p_session_id is null then pd.session_id is null else pd.session_id = p_session_id end)
       and (a->>'id') = p_agent_id and coalesce((a->>'actif')::boolean, true)
     limit 1;
    if v_rec is not null then
      v_found := true;
      v_ok := (v_rec->>'pinHash' = v_hash)
              or (coalesce(v_rec->>'pinClair','') <> '' and v_rec->>'pinClair' = p_pin);
      r_nom := v_rec->>'nom'; r_prenom := v_rec->>'prenom';
      r_qual := coalesce(v_rec->>'qualification','Agent');
      r_type := coalesce(v_rec->>'type','agent'); r_ent := v_rec->>'entreprise';
    end if;
  end if;

  if not v_found then
    select f.nom, f.prenom, (f.pin_hash = v_hash)
      into r_nom, r_prenom, v_ok
      from public.formateurs f
     where f.id::text = p_agent_id and f.center_id = p_center_id and f.actif = true
     limit 1;
    if r_nom is not null then
      v_found := true; r_qual := 'SSIAP 2'; r_type := 'formateur'; r_ent := coalesce(v_center_nom,'');
    end if;
    if v_ok is null then v_ok := false; end if;
  end if;

  if not v_found then v_ok := false; end if;
  perform public._login_throttle_record(v_ok);
  return query select v_ok, false, r_nom, r_prenom, r_qual, r_type, r_ent;
end $fn$;

grant execute on function public.patrol_agents_list(uuid, uuid) to anon, authenticated;
grant execute on function public.patrol_resolve(uuid, uuid, text, text) to anon, authenticated;
