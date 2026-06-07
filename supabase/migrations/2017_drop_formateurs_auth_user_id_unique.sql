-- La table `formateurs` avait une contrainte UNIQUE sur `auth_user_id` qui
-- empêchait le partage d'un même auth user entre plusieurs lignes — or c'est
-- précisément ce qu'on veut pour qu'un formateur multi-centres ait un seul PIN
-- partagé. On retire cette contrainte.

alter table public.formateurs
  drop constraint if exists formateurs_auth_user_id_key;

-- On garde un index non-unique pour les lookups par auth_user_id.
create index if not exists idx_formateurs_auth_user_id
  on public.formateurs (auth_user_id)
  where auth_user_id is not null;
