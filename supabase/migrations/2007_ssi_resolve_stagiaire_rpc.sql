-- Pierre angulaire de l'isolation multi-formateurs côté stagiaire.
-- Appelée ANONYMEMENT par le PC stagiaire après saisie du PIN (raccourci installé
-- par le centre sur chaque PC de salle). Le PC ne connaît pas le sessions_formation_id ;
-- on le retrouve via la chaîne : stagiaires → session_participants → sessions_formation → ssi_sessions.
--
-- Sécurité :
--   - SECURITY DEFINER : indispensable car anon ne peut pas lire stagiaires/ssi_sessions par RLS
--   - Regex stricte ^[0-9]{6}$ : exactement 6 chiffres (format PIN MIB unifié)
--   - center_id obligatoire en paramètre : limite le scope de recherche au centre du raccourci
--   - Aucune information révélée si le PIN est inconnu (pas de distinction PIN-faux vs verrouillé)
--   - Si verrouillé suite à failed_attempts, retourne `locked=true` (le client peut afficher
--     un message générique sans révéler quel compte est verrouillé)
--   - Si PIN OK mais aucun formateur n'a démarré de session SSI : `no_active_session=true`
--     avec l'identité du stagiaire (pour message UX clair : « Yohan, en attente du formateur »)
--   - Si tout est OK : ssi_session_id + session_number + stagiaire_email pour handoff Supabase Auth
create or replace function public.ssi_resolve_stagiaire(
  p_center_id uuid,
  p_pin       text
) returns table(
  ssi_session_id        uuid,
  session_number        text,
  sessions_formation_id uuid,
  stagiaire_id          uuid,
  stagiaire_prenom      text,
  stagiaire_nom         text,
  stagiaire_email       text,
  formateur_nom         text,
  locked                boolean,
  no_active_session     boolean
)
language plpgsql
security definer
set search_path = 'public', 'extensions', 'auth'
as $function$
declare
  v_pin_hash text;
  v_stag_id  uuid;
  v_user_id  uuid;
  v_locked   timestamptz;
  v_attempts int;
  v_prenom   text;
  v_nom      text;
begin
  if p_center_id is null or p_pin !~ '^[0-9]{6}$' then
    return query select null::uuid, null::text, null::uuid, null::uuid,
                        null::text, null::text, null::text, null::text,
                        false, false;
    return;
  end if;

  v_pin_hash := encode(digest(p_pin, 'sha256'), 'hex');

  select s.id, s.auth_user_id, s.locked_until, s.failed_attempts, s.prenom, s.nom
    into v_stag_id, v_user_id, v_locked, v_attempts, v_prenom, v_nom
    from stagiaires s
   where s.center_id = p_center_id
     and s.pin_hash = v_pin_hash
     and s.actif = true
   limit 1;

  if v_stag_id is null then
    return query select null::uuid, null::text, null::uuid, null::uuid,
                        null::text, null::text, null::text, null::text,
                        false, false;
    return;
  end if;

  if v_locked is not null and v_locked > now() then
    return query select null::uuid, null::text, null::uuid, null::uuid,
                        null::text, null::text, null::text, null::text,
                        true, false;
    return;
  end if;

  return query
  select ssi.id,
         ssi.session_number,
         ssi.sessions_formation_id,
         v_stag_id,
         v_prenom,
         v_nom,
         (select u.email from auth.users u where u.id = v_user_id),
         case when f.id is null then null else trim(coalesce(f.prenom,'') || ' ' || coalesce(f.nom,'')) end,
         false,
         false
    from ssi_sessions ssi
    join session_participants sp on sp.session_id = ssi.sessions_formation_id
    left join formateurs f on f.id = ssi.formateur_id
   where sp.stagiaire_id = v_stag_id
     and ssi.center_id = p_center_id
     and ssi.status = 'en_cours'
   order by ssi.started_at desc
   limit 1;

  if not found then
    return query select null::uuid, null::text, null::uuid,
                        v_stag_id, v_prenom, v_nom,
                        (select u.email from auth.users u where u.id = v_user_id),
                        null::text, false, true;
  end if;
end
$function$;

revoke all on function public.ssi_resolve_stagiaire(uuid, text) from public;
grant execute on function public.ssi_resolve_stagiaire(uuid, text) to anon, authenticated;
