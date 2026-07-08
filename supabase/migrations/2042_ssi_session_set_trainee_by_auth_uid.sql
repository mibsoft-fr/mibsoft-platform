-- 2042 — Nom du stagiaire « Inconnu » : ssi_session_set_trainee ne renseignait
-- pas stagiaire_id pour les stagiaires SANS ligne `profiles`.
--
-- Le custom_access_token_hook ne pose les claims (app_role/center_id/linked_id)
-- que si une ligne profiles existe. Or certains stagiaires ont un auth_user_id
-- mais AUCUNE ligne profiles → jwt_app_role()/jwt_linked_id() null → la fonction
-- levait 'auth_required' et stagiaire_id restait null (nom « Inconnu »).
--
-- On dérive désormais l'identité du stagiaire depuis auth.uid() → stagiaires
-- (indépendant de profiles), et le centre depuis la ligne stagiaire.

CREATE OR REPLACE FUNCTION public.ssi_session_set_trainee(p_session_number text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_uid       uuid := auth.uid();
  v_stagiaire uuid;
  v_center    uuid;
  v_id        uuid;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'auth_required' USING ERRCODE = '42501';
  END IF;
  IF p_session_number IS NULL OR length(p_session_number) = 0 THEN
    RAISE EXCEPTION 'bad_request' USING ERRCODE = '22023';
  END IF;
  SELECT st.id, st.center_id INTO v_stagiaire, v_center
    FROM public.stagiaires st
   WHERE st.auth_user_id = v_uid
   LIMIT 1;
  IF v_stagiaire IS NULL THEN
    RAISE EXCEPTION 'forbidden' USING ERRCODE = '42501';
  END IF;
  UPDATE ssi_sessions s
     SET stagiaire_id = v_stagiaire
   WHERE s.session_number = p_session_number
     AND s.center_id      = v_center
     AND s.status         = 'en_cours'
   RETURNING s.id INTO v_id;
  RETURN v_id;
END
$function$;
