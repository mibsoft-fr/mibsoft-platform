import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
// Envoi e-mail via Mailgun (même fournisseur que le reste de la plateforme)
const MAILGUN_API_KEY = Deno.env.get('MAILGUN_API_KEY') || '';
const MAILGUN_DOMAIN = Deno.env.get('MAILGUN_DOMAIN') || 'mib-prevention.fr';
const MAILGUN_HOST = Deno.env.get('MAILGUN_HOST') || 'api.eu.mailgun.net';
const MAILGUN_FROM = Deno.env.get('MAILGUN_FROM') || `MIB Prévention <noreply@${MAILGUN_DOMAIN}>`;
const ALERT_EMAIL = Deno.env.get('ALERT_EMAIL') || 'contact@mib-prevention.fr';
// Envoi SMS via SMSFactor (alertes bloquantes uniquement)
const SMSFACTOR_TOKEN = Deno.env.get('SMSFACTOR_TOKEN') || '';
const ALERT_SMS_TO = Deno.env.get('ALERT_SMS_TO') || ''; // ex: "33612345678" (séparés par des virgules pour plusieurs)
const SMSFACTOR_SENDER = Deno.env.get('SMSFACTOR_SENDER') || '';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS'
};

const TH_ERROR_COUNT_1H = 10;
const TH_ERROR_RATE_PCT = 5;
const TH_EXPIRING_SOON = 7;
const TH_TABLE_ROWS = 1_000_000;
// Seuils "bloquant" (mode quick, toutes les 5 min)
const TH_ERRORS_5M = 8;             // pic d'erreurs sur 5 min
const TH_TRANSVERSE_CENTERS = 2;   // même erreur sur N centres distincts => transverse
const SMS_COOLDOWN_MIN = 30;       // pas plus d'un SMS / 30 min par signature d'alerte

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });

  // Corps optionnel (le cron POST sans corps -> body vide)
  let body: any = {};
  try { body = await req.json(); } catch { body = {}; }
  const mode = body?.mode === 'quick' ? 'quick' : 'full';

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE);

  // --- Mode test SMS : envoie un SMS de validation puis s'arrête ---
  if (body?.test_sms === true) {
    const txt = typeof body.text === 'string' && body.text.trim()
      ? body.text.trim().slice(0, 155)
      : 'MIB Prévention : test alerte SMS, le monitoring fonctionne.';
    const res = await sendSms(txt, body?.simulate === true);
    return json({ ok: res.sent, mode: 'test_sms', simulate: body?.simulate === true, sms: res });
  }

  const { data: run, error: rerr } = await admin.from('monitoring_runs').insert({ status: 'running' }).select('id').single();
  if (rerr || !run) {
    return json({ error: 'cant_start_run', detail: rerr?.message }, 500);
  }
  const runId = run.id;

  const checks: any = { mode };
  const alerts: any[] = [];

  // ===== Checks "bloquant" (toujours exécutés) =====
  try {
    const { error } = await admin.from('centers').select('id', { count: 'exact', head: true });
    if (error) throw error;
    checks.db_ping = { ok: true };
  } catch (e) {
    checks.db_ping = { ok: false, error: String(e?.message || e) };
    alerts.push({ severity: 'critical', blocking: true, source: 'health-monitor', title: 'Base de données injoignable', message: checks.db_ping.error });
  }

  try {
    const since5 = new Date(Date.now() - 5 * 60 * 1000).toISOString();
    const { data: recent } = await admin.from('app_logs').select('level, source, message, center_id').gte('ts', since5);
    const errs = (recent || []).filter(l => l.level === 'error');
    checks.errors_5m = { errors: errs.length };
    if (errs.length >= TH_ERRORS_5M) {
      alerts.push({ severity: 'critical', blocking: true, source: 'health-monitor', title: "Pic d'erreurs (5 min)", message: `${errs.length} erreurs en 5 min (seuil ${TH_ERRORS_5M}).`, context: { since: since5, errors: errs.length } });
    }
    // Erreur transverse : même (source|message) sur >= N centres distincts
    const sig = new Map<string, Set<string>>();
    for (const e of errs) {
      if (!e.center_id) continue;
      const key = `${e.source || '?'}|${(e.message || '').slice(0, 80)}`;
      if (!sig.has(key)) sig.set(key, new Set());
      sig.get(key)!.add(e.center_id);
    }
    const transverse = [...sig.entries()].filter(([, s]) => s.size >= TH_TRANSVERSE_CENTERS);
    checks.transverse = { count: transverse.length };
    if (transverse.length > 0) {
      alerts.push({ severity: 'critical', blocking: true, source: 'health-monitor', title: 'Erreur transverse multi-centres', message: transverse.map(([k, s]) => `${k.split('|')[0]} sur ${s.size} centres`).join(' ; ').slice(0, 500), context: { since: since5, groups: transverse.map(([k, s]) => ({ sig: k, centers: s.size })) } });
    }
  } catch (e) {
    checks.errors_5m = { ok: false, error: String(e?.message || e) };
  }

  // ===== Checks d'audit complet (mode full uniquement) =====
  if (mode === 'full') {
    try {
      const since = new Date(Date.now() - 3600 * 1000).toISOString();
      const { data: lastHour } = await admin.from('app_logs').select('level').gte('ts', since);
      const total = lastHour?.length || 0;
      const errors = (lastHour || []).filter(l => l.level === 'error').length;
      const rate = total > 0 ? (errors / total) * 100 : 0;
      checks.errors_1h = { total, errors, rate_pct: Math.round(rate * 10) / 10 };
      if (errors >= TH_ERROR_COUNT_1H) {
        alerts.push({ severity: 'error', source: 'health-monitor', title: `${errors} erreurs en 1 h`, message: `Le seuil de ${TH_ERROR_COUNT_1H} erreurs/h est dépassé (taux ${checks.errors_1h.rate_pct}%).`, context: { since, errors, total } });
      } else if (rate >= TH_ERROR_RATE_PCT && total >= 20) {
        alerts.push({ severity: 'warning', source: 'health-monitor', title: `Taux d'erreur élevé ${checks.errors_1h.rate_pct}%`, message: `${errors} erreurs sur ${total} logs en 1 h.`, context: { since } });
      }
    } catch (e) {
      checks.errors_1h = { ok: false, error: String(e?.message || e) };
    }

    try {
      const { data: expiring } = await admin.from('licence_status_view').select('id, nom, days_remaining, license_status').lte('days_remaining', TH_EXPIRING_SOON).gte('days_remaining', 0);
      checks.expiring_soon = { count: expiring?.length || 0, centres: expiring };
      if (expiring && expiring.length > 0) {
        alerts.push({ severity: 'warning', source: 'health-monitor', title: `${expiring.length} centre(s) expirent dans ${TH_EXPIRING_SOON} jours`, message: expiring.map(c => `${c.nom} (J-${c.days_remaining})`).join(', '), context: { centres: expiring } });
      }
    } catch (e) {
      checks.expiring_soon = { ok: false, error: String(e?.message || e) };
    }

    try {
      const { data: expired } = await admin.from('licence_status_view').select('id, nom, days_remaining, license_status').eq('expiration_bucket', 'expire').eq('license_status', 'active');
      checks.expired_active = { count: expired?.length || 0, centres: expired };
      if (expired && expired.length > 0) {
        alerts.push({ severity: 'warning', source: 'health-monitor', title: `${expired.length} centre(s) expirés sont encore actifs`, message: expired.map(c => c.nom).join(', '), context: { centres: expired } });
      }
    } catch (e) {
      checks.expired_active = { ok: false, error: String(e?.message || e) };
    }

    try {
      const { count } = await admin.from('app_logs').select('*', { count: 'exact', head: true });
      checks.app_logs_size = { rows: count || 0 };
      if (count && count > TH_TABLE_ROWS) {
        alerts.push({ severity: 'warning', source: 'health-monitor', title: `Table app_logs volumineuse`, message: `${count.toLocaleString('fr-FR')} lignes — envisager une purge.`, context: { rows: count } });
      }
    } catch (e) {
      checks.app_logs_size = { ok: false, error: String(e?.message || e) };
    }

    try {
      const cutoff = new Date(Date.now() - 7 * 24 * 3600 * 1000).toISOString();
      const { count } = await admin.from('avis_retours').select('*', { count: 'exact', head: true }).eq('statut', 'nouveau').lt('created_at', cutoff);
      checks.avis_anciens = { count: count || 0 };
      if (count && count > 0) {
        alerts.push({ severity: 'info', source: 'health-monitor', title: `${count} avis non traité depuis +7j`, message: 'Rappel : traité les avis stagiaires/formateurs.', context: { older_than: cutoff } });
      }
    } catch (e) {
      checks.avis_anciens = { ok: false, error: String(e?.message || e) };
    }
  }

  // ===== Persistance des alertes (dedup par source+title tant que non résolue) =====
  let alertsCreated = 0;
  for (const a of alerts) {
    const { data: dup } = await admin.from('monitoring_alerts').select('id').eq('source', a.source).eq('title', a.title).eq('resolved', false).limit(1);
    if (dup && dup.length > 0) continue;
    const { error: ierr } = await admin.from('monitoring_alerts').insert(a);
    if (!ierr) alertsCreated++;
  }

  // ===== Escalade e-mail (erreur/critique) =====
  const critical = alerts.filter(a => a.severity === 'error' || a.severity === 'critical');
  let emailStatus: any = { sent: false };
  if (critical.length > 0 && MAILGUN_API_KEY && ALERT_EMAIL) {
    try {
      const subject = `[MIB] ${critical.length} alerte(s) ${critical.some(a => a.severity === 'critical') ? 'CRITIQUE' : 'erreur'}`;
      const html = `<h2>Monitoring MIB Prévention</h2>
        <p>Run #${runId} — ${new Date().toLocaleString('fr-FR')}</p>
        <h3>Alertes (${critical.length})</h3>
        <ul>${critical.map(a => `<li><strong>[${a.severity}]${a.blocking ? ' BLOQUANT' : ''}</strong> ${escapeHtml(a.title)}<br><small>${escapeHtml(a.message || '')}</small></li>`).join('')}</ul>
        <p>Voir les détails sur admin.html (onglet Monitoring).</p>`;
      const form = new FormData();
      form.append('from', MAILGUN_FROM);
      form.append('to', ALERT_EMAIL);
      form.append('subject', subject);
      form.append('html', html);
      const r = await fetch(`https://${MAILGUN_HOST}/v3/${MAILGUN_DOMAIN}/messages`, {
        method: 'POST',
        headers: { 'Authorization': `Basic ${btoa(`api:${MAILGUN_API_KEY}`)}` },
        body: form
      });
      const bodyTxt = await r.text();
      emailStatus = { sent: r.ok, status: r.status, body: bodyTxt.slice(0, 500) };
      if (r.ok) {
        await admin.from('monitoring_alerts').update({ email_sent: true }).in('title', critical.map(a => a.title)).eq('email_sent', false);
      }
    } catch (e) {
      emailStatus = { sent: false, error: String(e?.message || e) };
    }
  } else if (critical.length > 0) {
    emailStatus = { sent: false, reason: !MAILGUN_API_KEY ? 'no_mailgun_key' : 'no_alert_email' };
  }
  const emailMissing = [!MAILGUN_API_KEY && 'MAILGUN_API_KEY', !ALERT_EMAIL && 'ALERT_EMAIL'].filter(Boolean);
  checks.email = { ...emailStatus, provider: 'mailgun', recipient: ALERT_EMAIL, configured: emailMissing.length === 0, missing: emailMissing };

  // ===== Escalade SMS (alertes BLOQUANTES uniquement, avec cooldown) =====
  const smsWorthy = alerts.filter(a => a.blocking === true);
  let smsStatus: any = { sent: false, reason: smsWorthy.length ? 'unknown' : 'no_blocking_alert' };
  if (smsWorthy.length > 0) {
    if (!SMSFACTOR_TOKEN || !ALERT_SMS_TO) {
      smsStatus = { sent: false, reason: !SMSFACTOR_TOKEN ? 'no_token' : 'no_recipient' };
    } else {
      const titles = smsWorthy.map(a => a.title);
      const { data: openRows } = await admin.from('monitoring_alerts').select('id, title, sms_sent_at').eq('resolved', false).in('title', titles);
      const cutoff = Date.now() - SMS_COOLDOWN_MIN * 60 * 1000;
      const due = (openRows || []).filter(r => !r.sms_sent_at || new Date(r.sms_sent_at).getTime() < cutoff);
      if (due.length === 0) {
        smsStatus = { sent: false, reason: 'cooldown' };
      } else {
        const text = buildSmsText(smsWorthy);
        const res = await sendSms(text, false);
        smsStatus = res;
        if (res.sent) {
          await admin.from('monitoring_alerts').update({ sms_sent: true, sms_sent_at: new Date().toISOString() }).in('id', due.map(r => r.id));
        }
      }
    }
  }
  const smsMissing = [!SMSFACTOR_TOKEN && 'SMSFACTOR_TOKEN', !ALERT_SMS_TO && 'ALERT_SMS_TO'].filter(Boolean);
  checks.sms = { ...smsStatus, provider: 'smsfactor', recipient: ALERT_SMS_TO ? 'set' : 'unset', configured: smsMissing.length === 0, missing: smsMissing };

  let runStatus: 'ok' | 'degraded' | 'failed' = 'ok';
  if (alerts.some(a => a.severity === 'critical')) runStatus = 'failed';
  else if (alerts.some(a => a.severity === 'warning' || a.severity === 'error')) runStatus = 'degraded';

  await admin.from('monitoring_runs').update({
    finished_at: new Date().toISOString(),
    status: runStatus,
    checks,
    alerts_created: alertsCreated
  }).eq('id', runId);

  return json({ ok: true, run_id: runId, mode, status: runStatus, alerts_created: alertsCreated, checks });
});

async function sendSms(text: string, simulate: boolean) {
  if (!SMSFACTOR_TOKEN) return { sent: false, reason: 'no_token' };
  if (!ALERT_SMS_TO) return { sent: false, reason: 'no_recipient' };
  try {
    const gsm = ALERT_SMS_TO.split(',').map(v => ({ value: v.trim() })).filter(g => g.value);
    const message: any = { text, pushtype: 'alert' };
    if (SMSFACTOR_SENDER) message.sender = SMSFACTOR_SENDER;
    const payload = { sms: { message, recipients: { gsm } } };
    const url = simulate ? 'https://api.smsfactor.com/send/simulate' : 'https://api.smsfactor.com/send';
    const r = await fetch(url, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${SMSFACTOR_TOKEN}`, 'Accept': 'application/json', 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    const t = await r.text();
    return { sent: r.ok, status: r.status, body: t.slice(0, 500) };
  } catch (e) {
    return { sent: false, error: String(e?.message || e) };
  }
}

function buildSmsText(list: any[]) {
  const head = 'MIB ALERTE BLOQUANTE';
  const lines = list.slice(0, 3).map(a => a.title).join(' | ');
  return `${head}: ${lines}`.slice(0, 155);
}

function json(obj: unknown, status = 200) {
  return new Response(JSON.stringify(obj), { status, headers: { ...cors, 'Content-Type': 'application/json' } });
}

function escapeHtml(s: string) {
  return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}
