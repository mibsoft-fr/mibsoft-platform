-- RPC publique pour récupérer le center_id d'une session SSI à partir de son UUID.
-- Utile pour la page de login stagiaire sur un autre PC : avant l'auth Supabase,
-- on a besoin du centre pour appeler login_pin_resolve avec le bon scope.
-- Pas de fuite de données sensibles : un UUID est ~impossible à deviner et on
-- ne retourne que le center_id, pas le contenu de la session.
create or replace function public.ssi_get_session_center(p_session_id uuid)
returns uuid
language sql
security definer
set search_path to 'public'
as $function$
  select center_id from public.ssi_sessions where id = p_session_id;
$function$;

grant execute on function public.ssi_get_session_center(uuid) to anon, authenticated;
