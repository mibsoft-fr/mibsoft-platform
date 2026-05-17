-- Lien manquant entre la session SSI (instance simulateur) et la session SSIAP (formation).
-- Sans cette FK, impossible de répondre « quelle session SSI active pour ce stagiaire ? »
-- car le stagiaire est rattaché à une sessions_formation via session_participants.
-- C'est la base de l'isolation multi-formateurs : chaque formateur démarre sa propre
-- session SSI sur SA sessions_formation, et l'index unique partial empêche les doublons.
alter table public.ssi_sessions
  add column if not exists sessions_formation_id uuid
    references public.sessions_formation(id) on delete set null;

create index if not exists idx_ssi_sessions_sessions_formation_id
  on public.ssi_sessions(sessions_formation_id);

-- Au plus une session SSI 'en_cours' par session SSIAP.
-- Partial unique : autorise NULL (lignes legacy sans lien).
create unique index if not exists idx_ssi_sessions_one_active_per_formation
  on public.ssi_sessions(sessions_formation_id)
  where status = 'en_cours' and sessions_formation_id is not null;

-- Cleanup des sessions 'en_cours' jamais closes (legacy, antérieures à 1j).
update public.ssi_sessions
   set status = 'terminee', ended_at = now()
 where status = 'en_cours'
   and created_at < now() - interval '1 day';
