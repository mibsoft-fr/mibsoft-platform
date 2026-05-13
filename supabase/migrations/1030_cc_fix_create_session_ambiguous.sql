-- Fix: `session_code` in the not-exists subquery resolves to the RETURNS TABLE
-- OUT parameter, shadowing public.cc_sessions.session_code. Qualify the column.
create or replace function public.cc_create_session(p_level smallint, p_config jsonb)
returns table(id uuid, session_code text)
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_code text;
  v_id   uuid;
begin
  loop
    v_code := upper(substr(md5(random()::text), 1, 6));
    exit when not exists (
      select 1 from public.cc_sessions s where s.session_code = v_code
    );
  end loop;

  insert into public.cc_sessions (session_code, level, config)
  values (v_code, p_level, coalesce(p_config, '{}'::jsonb))
  returning cc_sessions.id into v_id;

  return query select v_id, v_code;
end;
$function$;
