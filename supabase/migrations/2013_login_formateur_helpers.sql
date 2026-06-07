-- Helpers pour le login formateur :
--   * `auth_user_id_by_email`  : lookup d'un auth user par email (utilisé par
--     l'edge function `formateur-auth-sync` pour l'idempotence).
--   * `list_centers_public`    : liste publique des centres actifs (id, nom, plan)
--     consommée par les pages de login (formateur, stagiaire).

create or replace function public.auth_user_id_by_email(p_email text)
returns uuid
language sql
security definer
set search_path to 'auth'
as $$
  select id from auth.users where email = p_email limit 1;
$$;
revoke execute on function public.auth_user_id_by_email(text) from public, anon, authenticated;
grant   execute on function public.auth_user_id_by_email(text) to service_role;

create or replace function public.list_centers_public()
returns table(id uuid, nom text, plan text)
language sql
security definer
set search_path to 'public'
as $$
  select c.id, c.nom, c.plan
  from public.centers c
  where coalesce(c.license_status, 'active') in ('active', 'trial')
  order by c.nom;
$$;
grant execute on function public.list_centers_public() to anon, authenticated;
