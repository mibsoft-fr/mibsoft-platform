-- Étend cc_bridge_to_entrainement pour aussi répliquer les questions
-- échouées (cc_team_answers où is_correct=false) dans entrainement_reponses.
-- Nouvelle signature : on prend cc_session_id + cc_team_id au lieu de
-- score/max_score (la RPC lit elle-même cc_teams.total_correct/total_answered).
--
-- Pour chaque réponse fausse, on construit la jsonb `reponse` au format
-- attendu par qInfoFor() côté formateur :
--   { question, explication, niveau, source:'challenge-cup' }
-- On ne calcule pas la "bonne réponse texte" car résoudre l'index correct
-- vers le texte nécessiterait de jointer cc_question_options selon le type
-- (quiz/true-false/multiple-select/...) — trop complexe ici, l'utilisateur
-- aura le contexte via l'explication.

drop function if exists public.cc_bridge_to_entrainement(uuid, text, int, int, int);

create or replace function public.cc_bridge_to_entrainement(
  p_stagiaire_id   uuid,
  p_niveau         text,
  p_cc_session_id  uuid,
  p_cc_team_id     text,
  p_duree_secondes int default 0
)
returns uuid
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_center        uuid;
  v_total_correct int;
  v_total_answered int;
  v_entr_id       uuid;
  r               record;
begin
  -- 1. Stagiaire + son centre
  select center_id into v_center
  from public.stagiaires
  where id = p_stagiaire_id;
  if v_center is null then
    raise exception 'stagiaire introuvable: %', p_stagiaire_id;
  end if;

  -- 2. Score de l'équipe sur cc_teams
  select coalesce(total_correct, 0), coalesce(total_answered, 0)
    into v_total_correct, v_total_answered
  from public.cc_teams
  where id = p_cc_team_id and session_id = p_cc_session_id;

  if v_total_answered is null then v_total_answered := 0; end if;
  if v_total_correct  is null then v_total_correct  := 0; end if;

  -- 3. entrainement_sessions
  insert into public.entrainement_sessions
    (stagiaire_id, center_id, niveau, nb_questions, score, max_score, status, duree_secondes)
  values
    (p_stagiaire_id, v_center, p_niveau, v_total_answered, v_total_correct,
     v_total_answered, 'terminee', coalesce(p_duree_secondes, 0))
  returning id into v_entr_id;

  -- 4. entrainement_reponses pour chaque réponse fausse
  for r in
    select ta.question_id, ta.answer, q.question as q_text, q.explanation as q_expl
    from public.cc_team_answers ta
    left join public.cc_questions q on q.id = ta.question_id
    where ta.session_id = p_cc_session_id
      and ta.team_id    = p_cc_team_id
      and ta.is_correct = false
  loop
    insert into public.entrainement_reponses
      (session_id, question_id, reponse, est_correcte)
    values
      (v_entr_id,
       r.question_id,
       jsonb_build_object(
         'question',   coalesce(r.q_text, ''),
         'explication',coalesce(r.q_expl, ''),
         'niveau',     p_niveau,
         'source',     'challenge-cup',
         'choisie',    r.answer,
         'bonne',      null
       ),
       false);
  end loop;

  return v_entr_id;
end;
$function$;

grant execute on function public.cc_bridge_to_entrainement(uuid, text, uuid, text, int) to anon, authenticated;
