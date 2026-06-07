-- Journalisation du consentement RGPD (CGU + politique de confidentialité)
-- pour les rôles centre / formateur / stagiaire (+ admin).
-- Calqué sur le dispositif du challenge EDF (table rgpd_consents + RPC
-- record_rgpd_consent SECURITY DEFINER), adapté à la plateforme SSIAP :
-- session_id/team_name (spécifiques challenge) remplacés par center_id.

create table if not exists public.rgpd_consents (
  id              uuid primary key default gen_random_uuid(),
  role            text not null,
  client_id       text not null,
  consent_version text not null,
  email           text,
  center_id       uuid,
  user_agent      text,
  page            text,
  consented_at    timestamptz not null default now()
);

create index if not exists idx_rgpd_consents_role         on public.rgpd_consents(role);
create index if not exists idx_rgpd_consents_consented_at  on public.rgpd_consents(consented_at);

-- RLS activée sans policy de lecture publique : la consultation se fait côté
-- admin (service role). L'écriture passe exclusivement par la RPC ci-dessous
-- (SECURITY DEFINER), donc aucune policy d'insert anon n'est nécessaire.
alter table public.rgpd_consents enable row level security;

create or replace function public.record_rgpd_consent(
  p_role            text,
  p_client_id       text,
  p_consent_version text,
  p_email           text default null,
  p_center_id       uuid default null,
  p_user_agent      text default null,
  p_page            text default null
) returns uuid
language plpgsql
security definer
set search_path = 'public'
as $function$
declare
  v_id uuid;
begin
  if p_role not in ('centre','formateur','stagiaire','admin') then
    raise exception 'role RGPD invalide: %', p_role;
  end if;
  if coalesce(p_client_id,'') = '' or coalesce(p_consent_version,'') = '' then
    raise exception 'client_id et consent_version obligatoires';
  end if;
  insert into public.rgpd_consents(role, client_id, consent_version, email, center_id, user_agent, page)
  values (p_role, p_client_id, p_consent_version, nullif(p_email,''), p_center_id, p_user_agent, p_page)
  returning id into v_id;
  return v_id;
end
$function$;

revoke all on function public.record_rgpd_consent(text,text,text,text,uuid,text,text) from public;
grant execute on function public.record_rgpd_consent(text,text,text,text,uuid,text,text) to anon, authenticated;
