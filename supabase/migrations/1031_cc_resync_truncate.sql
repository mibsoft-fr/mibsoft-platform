-- Wipe destination cc_* data tables before full resync from source project.
-- Preserves cc_supervisors, cc_sessions, cc_teams, cc_team_answers, cc_logs.
truncate
  public.cc_question_options,
  public.cc_question_items,
  public.cc_question_pairs,
  public.cc_question_categories,
  public.cc_question_category_items,
  public.cc_question_decision_steps,
  public.cc_questions,
  public.cc_modules
restart identity cascade;
