-- Phase 0 : structure d'etablissement reutilisable pour le module Patrol.
-- Complete un plan SSI (ssi_plan_types, qui porte deja les NIVEAUX) avec les LOCAUX et le MATERIEL
-- (RIA / extincteurs / BAES / desenfumage). center_id NULL = modele global (template).
-- (Applique en prod via apply_migration le 2026-06-15.)
create table if not exists public.patrol_etablissements (
  id         uuid primary key default gen_random_uuid(),
  center_id  uuid references public.centers(id) on delete cascade,
  plan_key   text not null,
  nom        text not null,
  config     jsonb not null default '{"nom":"","batiments":[]}'::jsonb,
  materiels  jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index if not exists patrol_etab_center_plan_uidx
  on public.patrol_etablissements (coalesce(center_id, '00000000-0000-0000-0000-000000000000'::uuid), plan_key);

alter table public.patrol_etablissements enable row level security;
drop policy if exists patrol_etab_read on public.patrol_etablissements;
create policy patrol_etab_read on public.patrol_etablissements for select to anon, authenticated using (true);
grant select on public.patrol_etablissements to anon, authenticated;

insert into public.patrol_etablissements (center_id, plan_key, nom, config, materiels)
values (
  null, 'centre-commercial', 'Centre commercial',
  $cfg${
    "nom": "Centre commercial",
    "batiments": [{
      "id": "bat1", "nom": "Centre commercial",
      "secteurs": [
        {"id":"rdc","nom":"RDC","zones":["Hall d'entrée","Galerie marchande","Boutique A","Boutique B","Réserve","Local technique"]},
        {"id":"etage-1","nom":"1er étage","zones":["Espace restauration","Cinéma","Sanitaires","Circulation"]}
      ]
    }]
  }$cfg$::jsonb,
  $mat$[
    {"id":1,"nom":"RIA Hall d'entrée","type":"RIA","statut":"Opérationnel","localisation":"Centre commercial > RDC > Hall d'entrée","codeQR":"MAT-RIA-001"},
    {"id":2,"nom":"Extincteur CO2 Galerie","type":"Extincteur","statut":"Opérationnel","localisation":"Centre commercial > RDC > Galerie marchande","codeQR":"MAT-EXT-001"},
    {"id":3,"nom":"BAES Galerie marchande","type":"BAES","statut":"Opérationnel","localisation":"Centre commercial > RDC > Galerie marchande","codeQR":"MAT-BAES-001"},
    {"id":4,"nom":"Extincteur eau Boutique A","type":"Extincteur","statut":"Opérationnel","localisation":"Centre commercial > RDC > Boutique A","codeQR":"MAT-EXT-002"},
    {"id":5,"nom":"RIA Local technique","type":"RIA","statut":"Opérationnel","localisation":"Centre commercial > RDC > Local technique","codeQR":"MAT-RIA-002"},
    {"id":6,"nom":"RIA Espace restauration","type":"RIA","statut":"Opérationnel","localisation":"Centre commercial > 1er étage > Espace restauration","codeQR":"MAT-RIA-003"},
    {"id":7,"nom":"Extincteur CO2 Cinéma","type":"Extincteur","statut":"Opérationnel","localisation":"Centre commercial > 1er étage > Cinéma","codeQR":"MAT-EXT-003"},
    {"id":8,"nom":"BAES Circulation étage","type":"BAES","statut":"Opérationnel","localisation":"Centre commercial > 1er étage > Circulation","codeQR":"MAT-BAES-002"},
    {"id":9,"nom":"Commande désenfumage Cinéma","type":"Désenfumage","statut":"Opérationnel","localisation":"Centre commercial > 1er étage > Cinéma","codeQR":"MAT-DESENF-001"}
  ]$mat$::jsonb
)
on conflict do nothing;
