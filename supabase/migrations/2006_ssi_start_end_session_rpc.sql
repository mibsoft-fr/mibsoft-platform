-- RPC pour le formateur authentifié : démarrer / terminer une session SSI
-- liée à une session SSIAP qu'il possède.
--
-- ssi_start_session :
--   - Vérifie que l'appelant est un formateur authentifié dans le bon centre
--   - Vérifie qu'il possède la sessions_formation (ou qu'elle est non assignée)
--   - Ferme toute session SSI active sur cette SSIAP (cas crash/refresh formateur)
--   - Insère la nouvelle ssi_session avec status='en_cours'
--   - L'index unique partial idx_ssi_sessions_one_active_per_formation garantit
--     qu'on ne peut pas avoir 2 sessions SSI 'en_cours' sur la même SSIAP
--
-- ssi_end_session :
--   - Vérifie l'ownership (center_id + formateur_id du JWT)
--   - Passe la session en 'terminee' avec ended_at=now()
create or replace function public.ssi_start_session(
  p_sessions_formation_id uuid,
  p_session_number        text
) returns uuid
language plpgsql
security definer
set search_path = 'public'
as $function$
declare
  v_role         text := jwt_app_role();
  v_center_id    uuid := jwt_center_id();
  v_formateur_id uuid := jwt_linked_id();
  v_new_id       uuid;
begin
  if v_role <> 'formateur' or v_center_id is null or v_formateur_id is null then
    raise exception 'auth_required' using errcode = '42501';
  end if;

  if p_sessions_formation_id is null or p_session_number is null or length(p_session_number) = 0 then
    raise exception 'bad_request' using errcode = '22023';
  end if;

  -- Le formateur doit posséder cette session SSIAP (ou elle doit être non assignée dans son centre)
  if not exists (
    select 1 from sessions_formation sf
     where sf.id = p_sessions_formation_id
       and sf.center_id = v_center_id
       and (sf.formateur_id = v_formateur_id or sf.formateur_id is null)
  ) then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  -- Ferme proprement toute session SSI active sur cette SSIAP (idempotence)
  update ssi_sessions
     set status='terminee', ended_at=now()
   where sessions_formation_id = p_sessions_formation_id
     and status = 'en_cours';

  insert into ssi_sessions(center_id, formateur_id, sessions_formation_id, session_number, status, started_at)
  values (v_center_id, v_formateur_id, p_sessions_formation_id, p_session_number, 'en_cours', now())
  returning id into v_new_id;

  return v_new_id;
end
$function$;

revoke all on function public.ssi_start_session(uuid, text) from public, anon;
grant execute on function public.ssi_start_session(uuid, text) to authenticated;

create or replace function public.ssi_end_session(p_ssi_session_id uuid)
returns boolean
language plpgsql
security definer
set search_path = 'public'
as $function$
declare
  v_role         text := jwt_app_role();
  v_center_id    uuid := jwt_center_id();
  v_formateur_id uuid := jwt_linked_id();
  v_updated      int;
begin
  if v_role <> 'formateur' or v_center_id is null or v_formateur_id is null then
    raise exception 'auth_required' using errcode = '42501';
  end if;

  update ssi_sessions
     set status='terminee', ended_at=now()
   where id = p_ssi_session_id
     and center_id = v_center_id
     and formateur_id = v_formateur_id
     and status = 'en_cours';
  get diagnostics v_updated = row_count;

  return v_updated > 0;
end
$function$;

revoke all on function public.ssi_end_session(uuid) from public, anon;
grant execute on function public.ssi_end_session(uuid) to authenticated;
