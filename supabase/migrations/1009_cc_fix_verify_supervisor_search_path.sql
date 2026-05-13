-- pgcrypto's crypt() lives in the `extensions` schema on Supabase.
-- The original cc_verify_supervisor had `set search_path = public` which hid it.

create or replace function public.cc_verify_supervisor(p_email text, p_password text)
returns table (id uuid, email text, firstname text, lastname text, plan text)
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
  return query
  select s.id, s.email, s.firstname, s.lastname, s.plan
  from public.cc_supervisors s
  where s.email = p_email
    and s.status = 'active'
    and s.password_hash = extensions.crypt(p_password, s.password_hash);
end;
$$;

grant execute on function public.cc_verify_supervisor(text, text) to anon, authenticated;

notify pgrst, 'reload schema';
