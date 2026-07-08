-- 2039 — Correctif « Échec sauvegarde rapport : forbidden » (évaluation formateur).
--
-- ssi_set_rapport autorisait l'écriture via jwt_linked_id() (= profiles.linked_id),
-- alors que ssi_start_session enregistre formateur_id = formateurs.id (résolu
-- depuis auth.uid()). Pour un même formateur ces deux identifiants diffèrent
-- (profiles.linked_id ≠ formateurs.id), donc l'UPDATE ne touchait aucune ligne
-- → exception 'forbidden'. On aligne l'autorisation sur la MÊME résolution que
-- ssi_start_session : auth.uid() → formateurs.id.

CREATE OR REPLACE FUNCTION public.ssi_set_rapport(p_ssi_session_id uuid, p_rapport jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_uid       uuid := auth.uid();
  v_role      text := jwt_app_role();
  v_center    uuid := jwt_center_id();
  v_formateur uuid;
BEGIN
  IF v_uid IS NULL OR v_role <> 'formateur' OR v_center IS NULL THEN
    RAISE EXCEPTION 'auth_required' USING ERRCODE = '42501';
  END IF;
  IF p_ssi_session_id IS NULL THEN
    RAISE EXCEPTION 'bad_request' USING ERRCODE = '22023';
  END IF;
  -- Formateur dérivé de auth.uid() — cohérent avec ssi_start_session.
  SELECT f.id INTO v_formateur FROM public.formateurs f
   WHERE f.auth_user_id = v_uid AND f.center_id = v_center AND f.actif = true
   LIMIT 1;
  IF v_formateur IS NULL THEN
    RAISE EXCEPTION 'forbidden' USING ERRCODE = '42501';
  END IF;
  UPDATE ssi_sessions
     SET rapport = COALESCE(p_rapport, '{}'::jsonb)
   WHERE id           = p_ssi_session_id
     AND center_id    = v_center
     AND formateur_id = v_formateur;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'forbidden' USING ERRCODE = '42501';
  END IF;
END
$function$;
