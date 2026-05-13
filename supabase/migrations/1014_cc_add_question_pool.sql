-- Two pools of cc_questions:
--   'quiz'      : pure QCM / multi-réponses pour entraînement classique (~600 importées)
--   'challenge' : variété de 12 types pour le Challenge Cup
alter table public.cc_questions
  add column if not exists pool text default 'quiz'
  check (pool in ('quiz','challenge'));

update public.cc_questions
   set pool='challenge'
 where 'starter-pack' = any(tags) or 'handcrafted' = any(tags);

create index if not exists cc_questions_pool_idx on public.cc_questions(pool);
