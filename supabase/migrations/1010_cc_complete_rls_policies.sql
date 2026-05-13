-- Missing CRUD policies that the live game (and the future admin UI) need.

create policy "cc_sessions insert" on public.cc_sessions for insert with check (true);
create policy "cc_sessions delete" on public.cc_sessions for delete using (true);

create policy "cc_teams delete" on public.cc_teams for delete using (true);

create policy "cc_modules insert" on public.cc_modules for insert with check (true);
create policy "cc_modules update" on public.cc_modules for update using (true) with check (true);
create policy "cc_modules delete" on public.cc_modules for delete using (true);

create policy "cc_questions insert" on public.cc_questions for insert with check (true);
create policy "cc_questions update" on public.cc_questions for update using (true) with check (true);
create policy "cc_questions delete" on public.cc_questions for delete using (true);

create policy "options insert" on public.cc_question_options for insert with check (true);
create policy "options update" on public.cc_question_options for update using (true) with check (true);
create policy "options delete" on public.cc_question_options for delete using (true);
create policy "items insert" on public.cc_question_items for insert with check (true);
create policy "items update" on public.cc_question_items for update using (true) with check (true);
create policy "items delete" on public.cc_question_items for delete using (true);
create policy "pairs insert" on public.cc_question_pairs for insert with check (true);
create policy "pairs update" on public.cc_question_pairs for update using (true) with check (true);
create policy "pairs delete" on public.cc_question_pairs for delete using (true);
create policy "categories insert" on public.cc_question_categories for insert with check (true);
create policy "categories update" on public.cc_question_categories for update using (true) with check (true);
create policy "categories delete" on public.cc_question_categories for delete using (true);
create policy "cat items insert" on public.cc_question_category_items for insert with check (true);
create policy "cat items update" on public.cc_question_category_items for update using (true) with check (true);
create policy "cat items delete" on public.cc_question_category_items for delete using (true);
create policy "decision steps insert" on public.cc_question_decision_steps for insert with check (true);
create policy "decision steps update" on public.cc_question_decision_steps for update using (true) with check (true);
create policy "decision steps delete" on public.cc_question_decision_steps for delete using (true);

create policy "cc_team_answers update" on public.cc_team_answers for update using (true) with check (true);
create policy "cc_team_answers delete" on public.cc_team_answers for delete using (true);
