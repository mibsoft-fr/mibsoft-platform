-- RPC consommée par `center.html` au moment de créer un formateur : recherche
-- les formateurs actifs partageant le même email, dans tous les centres, afin de
-- proposer au responsable de centre de réutiliser le PIN/identité existante
-- plutôt que de générer un nouveau code.
--
-- SECURITY DEFINER (contourne RLS) : un responsable de centre ne peut pas voir
-- les formateurs des autres centres via la table directement (RLS). Mais ici on
-- expose juste le strict nécessaire (prénom/nom/centre/email) pour le dialog
-- de liaison. La RPC est appelée par `authenticated`, jamais par `anon`.

create or replace function public.find_formateur_by_email(p_email text)
returns table(
  formateur_id uuid,
  center_id uuid,
  center_nom text,
  prenom text,
  nom text,
  pin_hash text,
  pin_clair text,
  auth_user_id uuid
)
language sql
security definer
set search_path to 'public'
as $$
  select f.id, f.center_id, c.nom, f.prenom, f.nom, f.pin_hash, f.pin_clair, f.auth_user_id
  from public.formateurs f
  left join public.centers c on c.id = f.center_id
  where f.actif = true
    and lower(coalesce(f.email,'')) = lower(coalesce(p_email,''))
    and p_email is not null
    and p_email <> '';
$$;

revoke execute on function public.find_formateur_by_email(text) from public, anon;
grant   execute on function public.find_formateur_by_email(text) to authenticated;
