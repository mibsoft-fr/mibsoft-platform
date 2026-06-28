-- 2032 — Colonne "verifiee" sur les banques de questions.
-- But : en PRODUCTION, ne servir que les questions validées par le super-admin.
-- Cette migration (colonne + droit super-admin) s'applique à DEV et PROD.
-- L'enforcement "lecture vérifiée uniquement" est ajouté UNIQUEMENT sur la prod
-- (voir bloc commenté en bas) pour que la dev reste permissive pour les tests.

ALTER TABLE public.cc_questions ADD COLUMN IF NOT EXISTS verifiee boolean NOT NULL DEFAULT false;
ALTER TABLE public.questions    ADD COLUMN IF NOT EXISTS verifiee boolean NOT NULL DEFAULT false;

CREATE INDEX IF NOT EXISTS cc_questions_verifiee_idx ON public.cc_questions USING btree (verifiee) WHERE verifiee;
CREATE INDEX IF NOT EXISTS questions_verifiee_idx    ON public.questions    USING btree (verifiee) WHERE verifiee;

-- Le super-admin peut modifier "verifiee" sur la table questions
-- (cc_questions est déjà ouvert en écriture côté policies existantes).
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='questions' AND policyname='questions_superadmin_update'
  ) THEN
    CREATE POLICY questions_superadmin_update ON public.questions
      FOR UPDATE TO authenticated
      USING (jwt_is_super_admin()) WITH CHECK (jwt_is_super_admin());
  END IF;
END $$;

-- ─────────────────────────────────────────────────────────────────────────
-- PROD UNIQUEMENT (ne pas appliquer en dev) — enforcement lecture vérifiée :
--   CREATE POLICY cc_questions_prod_verified ON public.cc_questions
--     AS RESTRICTIVE FOR SELECT TO public USING (verifiee OR jwt_is_super_admin());
--   CREATE POLICY questions_prod_verified ON public.questions
--     AS RESTRICTIVE FOR SELECT TO public USING (verifiee OR jwt_is_super_admin());
-- ─────────────────────────────────────────────────────────────────────────
