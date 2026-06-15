-- Re-neutralisation : get_patrol_agents_from_formateurs ne doit plus exposer les PIN.
-- Le nouveau client (patrol-login-formateur.html) ne lit que id/nom/prenom et verifie le PIN
-- via patrol_resolve (cote serveur). On garde la signature pour ne rien casser, on renvoie NULL
-- pour pin_hash et pin_clair. (Applique en prod via apply_migration le 2026-06-15, apres merge #163.)
create or replace function public.get_patrol_agents_from_formateurs(p_center_id uuid)
 returns table(id uuid, nom text, prenom text, pin_hash text, pin_clair text, email text, telephone text)
 language sql security definer set search_path to 'public'
as $function$
  select f.id, f.nom, f.prenom, null::text, null::text, f.email, f.telephone
    from public.formateurs f
   where f.center_id = p_center_id and f.actif = true
   order by f.nom;
$function$;
