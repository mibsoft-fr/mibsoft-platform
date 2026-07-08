-- 2041 — Audit multi-centres : même correctif que 2040 appliqué à
-- sessions_formation_set_jury (sauvegarde du jury d'examen depuis le journal).
--
-- Un formateur peut être affecté à plusieurs centres. La fonction filtrait par
-- jwt_center_id()/jwt_linked_id() (centre par défaut du profil) → 'forbidden'
-- dès que la formation appartenait à un AUTRE centre du formateur. On dérive
-- désormais l'autorisation du centre de la FORMATION et on vérifie que
-- l'appelant (auth.uid()) en est le formateur actif propriétaire.
CREATE OR REPLACE FUNCTION public.sessions_formation_set_jury(p_id uuid, p_jury jsonb)
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
  IF p_id IS NULL THEN
    RAISE EXCEPTION 'bad_request' USING ERRCODE = '22023';
  END IF;
  UPDATE sessions_formation sf
     SET jury = COALESCE(p_jury, '[]'::jsonb)
   WHERE sf.id = p_id
     AND EXISTS (
       SELECT 1 FROM public.formateurs f
        WHERE f.auth_user_id = v_uid
          AND f.center_id    = sf.center_id
          AND f.actif        = true
          AND f.id           = sf.formateur_id
     );
  IF NOT FOUND THEN
    RAISE EXCEPTION 'forbidden' USING ERRCODE = '42501';
  END IF;
END
$function$;

-- Note d'audit : ssi_session_set_trainee utilise encore jwt_center_id()/
-- jwt_linked_id(), mais côté STAGIAIRE. Vérifié : aucun stagiaire n'est présent
-- dans plusieurs centres (1 auth_user_id = 1 centre), donc pas de risque
-- multi-centres. De plus, le nom du stagiaire est aussi diffusé au formateur
-- via le bus (TRAINEE_IDENTITY) — le journal reste correct même si la liaison
-- base échoue. Inchangé volontairement.
