-- 2036 — Réserver l'ÉCRITURE de la banque de questions Challenge Cup au super-admin (PROD).
--
-- Avant : INSERT/UPDATE/DELETE ouverts à `public` (true) sur cc_questions + toutes ses
-- sous-tables => n'importe qui (même anon) pouvait créer/modifier/supprimer des questions.
-- Après : écritures réservées à jwt_is_super_admin(). Lectures inchangées (le jeu Challenge Cup
-- et l'auto-entraînement doivent continuer à lire les questions).
--
-- ⚠️ PROD UNIQUEMENT — la DEV reste volontairement permissive : l'éditeur autonome
-- `challenge-cup-ssiap` écrit en anon (pas de session Supabase auth) et casserait sinon.
-- Garde-fou : on ne durcit QUE si le marqueur prod existe (policy `cc_questions_prod_verified`,
-- créée en prod uniquement par la migration 2032). En DEV ce marqueur est absent => no-op.
-- Idempotente.

do $$
declare
  t text;
begin
  if not exists (
    select 1 from pg_policies
    where schemaname='public' and tablename='cc_questions'
      and policyname='cc_questions_prod_verified'
  ) then
    raise notice '[2036] Marqueur prod absent (cc_questions_prod_verified) — DEV : banque laissee permissive, durcissement ignore.';
    return;
  end if;

  -- 1) Supprimer les policies d'écriture ouvertes (public/true)
  drop policy if exists "cc_questions insert"       on public.cc_questions;
  drop policy if exists "cc_questions update"       on public.cc_questions;
  drop policy if exists "cc_questions delete"       on public.cc_questions;
  drop policy if exists "cc_options insert"         on public.cc_question_options;
  drop policy if exists "cc_options update"         on public.cc_question_options;
  drop policy if exists "cc_options delete"         on public.cc_question_options;
  drop policy if exists "cc_items insert"           on public.cc_question_items;
  drop policy if exists "cc_items update"           on public.cc_question_items;
  drop policy if exists "cc_items delete"           on public.cc_question_items;
  drop policy if exists "cc_pairs insert"           on public.cc_question_pairs;
  drop policy if exists "cc_pairs update"           on public.cc_question_pairs;
  drop policy if exists "cc_pairs delete"           on public.cc_question_pairs;
  drop policy if exists "cc_categories insert"      on public.cc_question_categories;
  drop policy if exists "cc_categories update"      on public.cc_question_categories;
  drop policy if exists "cc_categories delete"      on public.cc_question_categories;
  drop policy if exists "cc_cat items insert"       on public.cc_question_category_items;
  drop policy if exists "cc_cat items update"       on public.cc_question_category_items;
  drop policy if exists "cc_cat items delete"       on public.cc_question_category_items;
  drop policy if exists "cc_decision steps insert"  on public.cc_question_decision_steps;
  drop policy if exists "cc_decision steps update"  on public.cc_question_decision_steps;
  drop policy if exists "cc_decision steps delete"  on public.cc_question_decision_steps;

  -- 2) (Re)créer des policies d'écriture réservées au super-admin sur chaque table
  foreach t in array array[
    'cc_questions','cc_question_options','cc_question_items','cc_question_pairs',
    'cc_question_categories','cc_question_category_items','cc_question_decision_steps'
  ] loop
    execute format('drop policy if exists %I on public.%I', t||'_superadmin_insert', t);
    execute format('drop policy if exists %I on public.%I', t||'_superadmin_update', t);
    execute format('drop policy if exists %I on public.%I', t||'_superadmin_delete', t);
    execute format('create policy %I on public.%I for insert to authenticated with check (jwt_is_super_admin())', t||'_superadmin_insert', t);
    execute format('create policy %I on public.%I for update to authenticated using (jwt_is_super_admin()) with check (jwt_is_super_admin())', t||'_superadmin_update', t);
    execute format('create policy %I on public.%I for delete to authenticated using (jwt_is_super_admin())', t||'_superadmin_delete', t);
  end loop;
end $$;
