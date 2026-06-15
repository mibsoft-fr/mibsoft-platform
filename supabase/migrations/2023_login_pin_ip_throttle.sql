-- Throttle anti-brute-force PAR IP sur les RPC de resolution PIN (login formateur/stagiaire).
-- Le login etant par PIN seul, on ne peut pas verrouiller "par compte" (un mauvais PIN n'identifie
-- aucun compte). On limite donc par IP : 5 echecs CONSECUTIFS (sans succes) -> blocage 15 min.
-- Un succes reinitialise le compteur de l'IP -> ne bloque pas les salles (IP partagee) tant que des
-- connexions reussissent. (Applique en prod via apply_migration le 2026-06-15.)

create table if not exists public.login_throttle (
  ip           text primary key,
  attempts     int  not null default 0,
  locked_until timestamptz,
  updated_at   timestamptz not null default now()
);
alter table public.login_throttle enable row level security;
revoke all on public.login_throttle from anon, authenticated;

create or replace function public._client_ip()
returns text language plpgsql security definer set search_path to 'public' as $fn$
declare h json; ip text;
begin
  begin h := current_setting('request.headers', true)::json; exception when others then h := null; end;
  if h is null then return 'unknown'; end if;
  ip := split_part(coalesce(h->>'x-forwarded-for',''), ',', 1);
  if ip = '' then ip := coalesce(h->>'x-real-ip',''); end if;
  if ip = '' then return 'unknown'; end if;
  return trim(ip);
end $fn$;

create or replace function public._login_throttle_blocked()
returns boolean language plpgsql security definer set search_path to 'public' as $fn$
declare v_ip text; v_until timestamptz;
begin
  v_ip := public._client_ip();
  if v_ip = 'unknown' then return false; end if;
  select locked_until into v_until from public.login_throttle where ip = v_ip;
  return (v_until is not null and v_until > now());
end $fn$;

create or replace function public._login_throttle_record(p_ok boolean)
returns void language plpgsql security definer set search_path to 'public' as $fn$
declare v_ip text; v_attempts int; v_updated timestamptz;
begin
  v_ip := public._client_ip();
  if v_ip = 'unknown' then return; end if;
  delete from public.login_throttle where updated_at < now() - interval '1 day';
  if p_ok then
    delete from public.login_throttle where ip = v_ip;
    return;
  end if;
  select attempts, updated_at into v_attempts, v_updated from public.login_throttle where ip = v_ip;
  if v_attempts is null or v_updated < now() - interval '15 minutes' then
    v_attempts := 1;
  else
    v_attempts := v_attempts + 1;
  end if;
  insert into public.login_throttle(ip, attempts, updated_at, locked_until)
    values (v_ip, v_attempts, now(), case when v_attempts >= 5 then now() + interval '15 minutes' else null end)
  on conflict (ip) do update
    set attempts = excluded.attempts, updated_at = excluded.updated_at, locked_until = excluded.locked_until;
end $fn$;

revoke all on function public._client_ip() from public, anon, authenticated;
revoke all on function public._login_throttle_blocked() from public, anon, authenticated;
revoke all on function public._login_throttle_record(boolean) from public, anon, authenticated;

-- NOTE : les 3 RPC login_pin_resolve / login_pin_resolve_multi / ssi_resolve_stagiaire ont ete
-- recreees a l'identique (depuis leur definition LIVE) en ajoutant, au debut, le controle
-- _login_throttle_blocked() (renvoie l'etat "locked"), et l'enregistrement _login_throttle_record()
-- selon que le PIN correspond (succes -> reset) ou non (echec -> +1). Voir l'historique apply_migration.
