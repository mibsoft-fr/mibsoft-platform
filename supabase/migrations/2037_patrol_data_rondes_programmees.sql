-- 2037 — Rondes programmées SSIAP Patrol.
-- Modèles de rondes réutilisables, lancés à la demande par le rondier, filtrés par
-- bâtiment / niveau / thématique. Stockés en jsonb sur patrol_data (une ligne par centre).
-- Chaque entrée : { id, nom, thematique, filtreType, batiment, niveau, zone, actif }.
-- Idempotente. Appliquée sur DEV et PROD.
alter table public.patrol_data
  add column if not exists rondes_programmees jsonb not null default '[]'::jsonb;
