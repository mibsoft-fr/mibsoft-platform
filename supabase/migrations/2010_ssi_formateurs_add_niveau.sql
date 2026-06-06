-- Ajoute la colonne `niveau` à `formateurs` (utilisée par center.html lors de la
-- création/modification d'un formateur). Valeurs attendues : 'SSIAP1', 'SSIAP2',
-- 'SSIAP3', ou NULL.

alter table public.formateurs
  add column if not exists niveau text;

-- Recharge le schema cache de PostgREST pour que l'API expose la colonne tout de suite.
notify pgrst, 'reload schema';
