-- 2043 — Assignation manuelle du stagiaire d'une session par le formateur.
--
-- Filet quand la détection auto échoue (ex. stagiaire non connecté / auth
-- expirée) : le formateur peut choisir le stagiaire d'une session depuis le
-- journal (menu déroulant des inscrits). Deux RPC :
--   - ssi_formation_stagiaires : liste des stagiaires inscrits à la formation.
--   - ssi_set_session_trainee  : écrit ssi_sessions.stagiaire_id.
-- Autorisation dérivée du centre de la session/formation (compatible formateur
-- multi-centres), l'appelant devant en être le formateur actif propriétaire.

CREATE OR REPLACE FUNCTION public.ssi_formation_stagiaires(p_sessions_formation_id uuid)
 RETURNS TABLE(id uuid, prenom text, nom text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_uid uuid := auth.uid();
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'auth_required' USING ERRCODE='42501'; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM sessions_formation sf
     JOIN formateurs f ON f.center_id = sf.center_id
    WHERE sf.id = p_sessions_formation_id
      AND f.auth_user_id = v_uid AND f.actif = true
  ) THEN
    RAISE EXCEPTION 'forbidden' USING ERRCODE='42501';
  END IF;
  RETURN QUERY
    SELECT st.id, st.prenom, st.nom
      FROM session_participants sp
      JOIN stagiaires st ON st.id = sp.stagiaire_id
     WHERE sp.session_id = p_sessions_formation_id
     ORDER BY st.nom, st.prenom;
END
$function$;

CREATE OR REPLACE FUNCTION public.ssi_set_session_trainee(p_ssi_session_id uuid, p_stagiaire_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_uid uuid := auth.uid();
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'auth_required' USING ERRCODE='42501'; END IF;
  IF p_ssi_session_id IS NULL THEN RAISE EXCEPTION 'bad_request' USING ERRCODE='22023'; END IF;
  UPDATE ssi_sessions s
     SET stagiaire_id = p_stagiaire_id
   WHERE s.id = p_ssi_session_id
     AND EXISTS (
       SELECT 1 FROM formateurs f
        WHERE f.auth_user_id = v_uid AND f.center_id = s.center_id
          AND f.actif = true AND f.id = s.formateur_id
     )
     AND (
       p_stagiaire_id IS NULL
       OR EXISTS (SELECT 1 FROM stagiaires st WHERE st.id = p_stagiaire_id AND st.center_id = s.center_id)
     );
  IF NOT FOUND THEN RAISE EXCEPTION 'forbidden' USING ERRCODE='42501'; END IF;
END
$function$;
