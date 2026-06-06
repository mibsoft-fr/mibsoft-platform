-- Ajoute les colonnes `niveau` et `date_dernier_recyclage` à `formateurs`.
-- `niveau`                 : valeurs attendues 'SSIAP1', 'SSIAP2', 'SSIAP3' ou NULL.
-- `date_dernier_recyclage` : date du dernier recyclage SSIAP, utilisée pour
--                            calculer l'échéance des 3 ans (alerte 6 mois avant).

alter table public.formateurs
  add column if not exists niveau text,
  add column if not exists date_dernier_recyclage date;

-- Recharge le schema cache de PostgREST pour que l'API expose les colonnes tout de suite.
notify pgrst, 'reload schema';
