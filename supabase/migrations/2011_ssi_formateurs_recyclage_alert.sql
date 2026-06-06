-- Suivi des notifications de recyclage SSIAP envoyées aux centres.
-- Permet à la edge function `formateurs-recyclage-watch` de ne pas spammer :
-- on n'envoie un mail que si l'état (soon|expired) change OU si le dernier
-- envoi date de plus de 14 jours.

alter table public.formateurs
  add column if not exists recyclage_alert_state text,    -- 'soon' | 'expired' | null
  add column if not exists recyclage_alert_sent_at timestamptz;

notify pgrst, 'reload schema';
