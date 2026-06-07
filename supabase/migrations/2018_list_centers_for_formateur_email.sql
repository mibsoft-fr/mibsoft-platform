-- RPC consommée par `login-formateur.html` (nouveau flow email-first) : à partir
-- d'un email, liste les centres actifs où ce formateur est inscrit. Ne renvoie
-- aucune info sensible (juste id/nom/plan du centre). Permet au front d'afficher
-- la liste des centres du formateur sans qu'il ait à les sélectionner parmi
-- tous les centres de la plateforme.

create or replace function public.list_centers_for_formateur_email(p_email text)
returns table(id uuid, nom text, plan text)
language sql
security definer
set search_path to 'public'
as $$
  select distinct c.id, c.nom, c.plan
  from public.formateurs f
  join public.centers c on c.id = f.center_id
  where f.actif = true
    and lower(coalesce(f.email,'')) = lower(coalesce(p_email,''))
    and p_email is not null
    and p_email <> ''
  order by c.nom;
$$;

grant execute on function public.list_centers_for_formateur_email(text) to anon, authenticated;
