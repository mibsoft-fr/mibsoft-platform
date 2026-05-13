-- =====================================================================
-- Seed : superviseur par défaut (mot de passe haché en bcrypt)
-- Email : admin@ssiap.local
-- Mot de passe : SSIAP2025  (à changer en production)
-- =====================================================================

insert into public.cc_supervisors (email, password_hash, firstname, lastname, plan)
values (
  'admin@ssiap.local',
  crypt('SSIAP2025', gen_salt('bf', 10)),
  'Admin',
  'SSIAP',
  'DEMO'
)
on conflict (email) do nothing;
