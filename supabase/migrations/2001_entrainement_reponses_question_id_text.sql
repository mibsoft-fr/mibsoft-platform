-- entrainement_reponses.question_id : UUID → TEXT + drop FK obsolète
--
-- Contexte : depuis le refactor auto-entrainement.html (PR #30), les questions
-- ne viennent plus de public.questions mais des JSON statiques
-- challenge-cup-ssiap/data/ssiap*_FINAL_200.json. Les IDs JSON sont des entiers
-- (0-199). Le code envoie `question_id: String(q.id)` (chaîne "0", "1", ...).
-- La colonne étant UUID, Postgres rejette avec
-- "invalid input syntax for type uuid". Tous les inserts de réponses depuis
-- PR #30 ont été silencieusement perdus (le code utilise
-- `.then(()=>{}, ()=>{})` qui swallow tout).
--
-- Les 35 réponses pré-existantes sont toutes UUID-shaped : la migration
-- USING question_id::text les préserve verbatim. Le FK vers questions(id)
-- est obsolète (les IDs JSON ne sont pas dans cette table) et bloque
-- ALTER → on le drop.
alter table public.entrainement_reponses
  drop constraint if exists entrainement_reponses_question_id_fkey;

alter table public.entrainement_reponses
  alter column question_id type text
  using question_id::text;
