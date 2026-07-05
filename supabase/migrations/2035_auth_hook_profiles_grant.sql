-- 2035 — Correctif Custom Access Token Hook : accès profiles pour supabase_auth_admin.
-- Le hook public.custom_access_token_hook lit public.profiles ; il s'exécute sous le rôle
-- supabase_auth_admin qui doit donc pouvoir lire cette table. Ce droit existait en DEV mais
-- n'avait pas été cloné en PROD → "permission denied for table profiles" → tout login/reset
-- échouait ("Error running hook"). Idempotent. Déjà appliqué à PROD via MCP.

grant usage on schema public to supabase_auth_admin;
grant select on public.profiles to supabase_auth_admin;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='profiles' AND policyname='auth_admin_read_profiles'
  ) THEN
    CREATE POLICY auth_admin_read_profiles ON public.profiles
      FOR SELECT TO supabase_auth_admin USING (true);
  END IF;
END $$;
