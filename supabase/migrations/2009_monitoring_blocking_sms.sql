-- Monitoring : détection des problèmes bloquants + escalade SMS
-- Colonnes additives sur monitoring_alerts pour marquer les alertes bloquantes
-- et tracer l'envoi des SMS (avec cooldown géré côté edge function health-monitor).

alter table public.monitoring_alerts
  add column if not exists blocking boolean not null default false,
  add column if not exists sms_sent boolean not null default false,
  add column if not exists sms_sent_at timestamptz;

-- Accélère la déduplication des alertes ouvertes par signature (source, title).
create index if not exists idx_monitoring_alerts_open_sig
  on public.monitoring_alerts (source, title) where resolved = false;
