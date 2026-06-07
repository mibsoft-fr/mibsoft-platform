-- Les RPC `ssi_start_session` et `ssi_end_session` (mig 2006) requéraient les
-- claims JWT `jwt_app_role()`, `jwt_center_id()`, `jwt_linked_id()` — qui ne
-- sont peuplés que pour les comptes centre. Les formateurs (auth users
-- synthétiques créés par formateur-auth-sync) n'ont aucun de ces claims, donc
-- la RPC échouait avec « auth_required » dès le démarrage d'une session SSI.
--
-- On refond la sécurité pour s'appuyer sur `auth.uid()` + la table `formateurs`
-- (jointure : un auth user peut être lié à plusieurs lignes formateurs, une par
-- centre où il intervient). On résout le bon `formateur_id` en croisant avec
-- le `center_id` de la sessions_formation cible.

create or replace function public.ssi_start_session(
  p_sessions_formation_id uuid,
  p_session_number        text
) returns uuid
language plpgsql
security definer
set search_path = 'public'
as $function$
declare
  v_uid          uuid := auth.uid();
  v_center_id    uuid;
  v_formateur_id uuid;
  v_new_id       uuid;
begin
  if v_uid is null then
    raise exception 'auth_required' using errcode = '42501';
  end if;
  if p_sessions_formation_id is null or p_session_number is null or length(p_session_number) = 0 then
    raise exception 'bad_request' using errcode = '22023';
  end if;

  -- Centre de la session SSIAP cible
  select sf.center_id into v_center_id
    from sessions_formation sf
   where sf.id = p_sessions_formation_id;
  if v_center_id is null then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  -- Ligne formateurs correspondant à ce centre (dédup multi-centres : un auth
  -- user peut avoir plusieurs lignes, une par centre)
  select f.id into v_formateur_id
    from public.formateurs f
   where f.auth_user_id = v_uid
     and f.center_id    = v_center_id
     and f.actif        = true
   limit 1;
  if v_formateur_id is null then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  -- Le formateur doit être responsable de la session (ou la session non assignée)
  if not exists (
    select 1 from sessions_formation sf
     where sf.id = p_sessions_formation_id
       and sf.center_id = v_center_id
       and (sf.formateur_id = v_formateur_id or sf.formateur_id is null)
  ) then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  -- Idempotence : ferme toute session SSI active sur cette SSIAP
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
  v_uid     uuid := auth.uid();
  v_updated int;
begin
  if v_uid is null then
    raise exception 'auth_required' using errcode = '42501';
  end if;

  update ssi_sessions s
     set status='terminee', ended_at=now()
   where s.id = p_ssi_session_id
     and s.status = 'en_cours'
     and exists (
       select 1 from public.formateurs f
        where f.auth_user_id = v_uid
          and f.id           = s.formateur_id
          and f.actif        = true
     );
  get diagnostics v_updated = row_count;

  return v_updated > 0;
end
$function$;

revoke all on function public.ssi_end_session(uuid) from public, anon;
grant execute on function public.ssi_end_session(uuid) to authenticated;
