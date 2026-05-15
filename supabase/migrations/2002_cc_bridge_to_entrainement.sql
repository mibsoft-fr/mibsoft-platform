-- RPC pour ponter une session Challenge Cup vers entrainement_sessions
-- afin que les résultats d'un stagiaire en mode invitation (équipe id 'mib_<uuid>')
-- remontent dans le dashboard formateur (qui ne lit que entrainement_sessions).
-- SECURITY DEFINER → bypass RLS de entrainement_sessions (qui exige
-- authenticated + center_id = jwt_center_id()). La sécurité est portée par
-- la fonction elle-même : on vérifie que p_stagiaire_id existe bien.
create or replace function public.cc_bridge_to_entrainement(
  p_stagiaire_id uuid,
  p_niveau text,
  p_score int,
  p_max_score int,
  p_duree_secondes int default 0
)
returns uuid
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_center uuid;
  v_id    uuid;
begin
  select center_id into v_center
  from public.stagiaires
  where id = p_stagiaire_id;
  if v_center is null then
    raise exception 'stagiaire introuvable: %', p_stagiaire_id;
  end if;
  insert into public.entrainement_sessions
    (stagiaire_id, center_id, niveau, nb_questions, score, max_score, status, duree_secondes)
  values
    (p_stagiaire_id, v_center, p_niveau, p_max_score, p_score, p_max_score, 'terminee', coalesce(p_duree_secondes, 0))
  returning id into v_id;
  return v_id;
end;
$function$;

grant execute on function public.cc_bridge_to_entrainement(uuid, text, int, int, int) to anon, authenticated;
