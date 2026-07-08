-- 2040 — Correctif (bis) « Échec sauvegarde rapport : forbidden ».
--
-- 2039 alignait l'autorisation sur auth.uid() → formateurs.id MAIS en filtrant
-- par jwt_center_id(). Or un formateur peut appartenir à PLUSIEURS centres
-- (plusieurs lignes `formateurs` pour le même auth_user_id). Les claims JWT
-- (center_id/linked_id, issus de `profiles`) pointent vers UN centre par défaut,
-- pas forcément celui de la session en cours → l'UPDATE échouait encore.
--
-- On dérive désormais l'autorisation du CENTRE DE LA SESSION (comme
-- ssi_start_session via la formation) et on vérifie que l'appelant (auth.uid())
-- est le formateur actif propriétaire de la session dans ce centre. Aucune
-- dépendance aux claims JWT (center_id/linked_id/app_role).

CREATE OR REPLACE FUNCTION public.ssi_set_rapport(p_ssi_session_id uuid, p_rapport jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_uid uuid := auth.uid();
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'auth_required' USING ERRCODE = '42501';
  END IF;
  IF p_ssi_session_id IS NULL THEN
    RAISE EXCEPTION 'bad_request' USING ERRCODE = '22023';
  END IF;
  UPDATE ssi_sessions s
     SET rapport = COALESCE(p_rapport, '{}'::jsonb)
   WHERE s.id = p_ssi_session_id
     AND EXISTS (
       SELECT 1 FROM public.formateurs f
        WHERE f.auth_user_id = v_uid
          AND f.center_id    = s.center_id
          AND f.actif        = true
          AND f.id           = s.formateur_id
     );
  IF NOT FOUND THEN
    RAISE EXCEPTION 'forbidden' USING ERRCODE = '42501';
  END IF;
END
$function$;
