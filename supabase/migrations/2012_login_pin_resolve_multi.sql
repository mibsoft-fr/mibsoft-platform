-- Nouvelle RPC pour le login formateur : renvoie TOUTES les correspondances PIN
-- au lieu d'une seule (LIMIT 1 de login_pin_resolve). Permet au front d'afficher
-- un sélecteur de centre quand un formateur est inscrit dans plusieurs centres.
--
-- Retourne aussi le nom et le plan du centre pour l'affichage du picker, et le
-- niveau du formateur. Verrouillage : on renvoie la ligne avec `locked = true`,
-- le front filtre ou affiche un message clair.

create or replace function public.login_pin_resolve_multi(
  p_center_id uuid,    -- optionnel, restreint à un centre si fourni (ex: QR code)
  p_role app_role,
  p_pin text
)
returns table(
  formateur_id uuid,
  email text,
  locked boolean,
  center_id uuid,
  center_nom text,
  center_plan text,
  niveau text
)
language plpgsql
security definer
set search_path to 'public', 'auth', 'extensions'
as $$
declare
  v_pin_hash text;
begin
  if p_pin !~ '^[0-9]{4,8}$' then
    return;
  end if;
  v_pin_hash := encode(digest(p_pin, 'sha256'), 'hex');

  if p_role = 'formateur' then
    return query
      select
        f.id,
        u.email::text,
        (f.locked_until is not null and f.locked_until > now()),
        f.center_id,
        c.nom,
        c.plan,
        f.niveau
      from public.formateurs f
      left join auth.users u on u.id = f.auth_user_id
      left join public.centers c on c.id = f.center_id
      where f.pin_hash = v_pin_hash
        and f.actif = true
        and (p_center_id is null or f.center_id = p_center_id)
        and u.email is not null;
  end if;
end;
$$;

grant execute on function public.login_pin_resolve_multi(uuid, app_role, text) to anon, authenticated;
