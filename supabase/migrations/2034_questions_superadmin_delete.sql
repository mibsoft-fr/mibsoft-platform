-- 2034 — Autoriser le super-admin à SUPPRIMER des questions depuis la Banque de questions (admin).
-- En PROD, seules des policies restreintes existent (SELECT vérifié + UPDATE super-admin) : sans
-- policy DELETE, la suppression est refusée. On ajoute donc une policy DELETE réservée au super-admin
-- sur les deux banques. Les tables enfants de cc_questions (options, items, pairs, etc.) sont en
-- ON DELETE CASCADE, donc supprimées automatiquement. Idempotente.

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='cc_questions' AND policyname='cc_questions_superadmin_delete'
  ) THEN
    CREATE POLICY cc_questions_superadmin_delete ON public.cc_questions
      FOR DELETE TO authenticated
      USING (jwt_is_super_admin());
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='questions' AND policyname='questions_superadmin_delete'
  ) THEN
    CREATE POLICY questions_superadmin_delete ON public.questions
      FOR DELETE TO authenticated
      USING (jwt_is_super_admin());
  END IF;
END $$;
