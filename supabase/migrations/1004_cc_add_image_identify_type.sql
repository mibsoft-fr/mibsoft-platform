-- =====================================================================
-- Adjustments after extracting cc_questions from index.html:
--   - the existing data uses type 'image-identify' (not 'pictogram')
--   - cc_questions have imageKey + imageDesc (reference to local SVG dict)
-- =====================================================================

alter table public.cc_questions drop constraint cc_questions_type_check;
alter table public.cc_questions add constraint cc_questions_type_check
  check (type in (
    'quiz','true-false','multiple-select','sequence','ranking',
    'matching','fill-blank','find-intruder','scenario',
    'categories','decision','image-identify'
  ));

alter table public.cc_questions
  add column image_key  text,
  add column image_desc text;
