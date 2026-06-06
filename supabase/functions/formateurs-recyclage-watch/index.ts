import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const MAILGUN_API_KEY = Deno.env.get('MAILGUN_API_KEY') || '';
const MAILGUN_DOMAIN = Deno.env.get('MAILGUN_DOMAIN') || 'mib-prevention.fr';
const MAILGUN_HOST = Deno.env.get('MAILGUN_HOST') || 'api.eu.mailgun.net';
const MAILGUN_FROM = Deno.env.get('MAILGUN_FROM') || `MIB Prévention <noreply@${MAILGUN_DOMAIN}>`;

// Cooldown : on ne re-notifie pas le même formateur pour le même état avant N jours.
const COOLDOWN_DAYS = 14;
// Échéance des 3 ans après le dernier recyclage SSIAP.
const RECYCLAGE_YEARS = 3;
// Fenêtre d'alerte « bientôt » : 6 mois avant l'échéance.
const SOON_MONTHS = 6;

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS'
};

type State = 'ok' | 'soon' | 'expired';

function computeState(dateStr: string | null): { state: State, due: Date | null } {
  if (!dateStr) return { state: 'ok', due: null };
  const last = new Date(dateStr);
  if (isNaN(last.getTime())) return { state: 'ok', due: null };
  const due = new Date(last);
  due.setFullYear(due.getFullYear() + RECYCLAGE_YEARS);
  const now = new Date();
  if (now >= due) return { state: 'expired', due };
  const soonThreshold = new Date(due);
  soonThreshold.setMonth(soonThreshold.getMonth() - SOON_MONTHS);
  if (now >= soonThreshold) return { state: 'soon', due };
  return { state: 'ok', due };
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });

  let body: any = {};
  try { body = await req.json(); } catch { body = {}; }
  const dryRun = body?.dry_run === true;

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE);

  const { data: formateurs, error } = await admin
    .from('formateurs')
    .select('id, prenom, nom, niveau, date_dernier_recyclage, recyclage_alert_state, recyclage_alert_sent_at, center_id, centers ( id, nom, email )')
    .eq('actif', true)
    .not('date_dernier_recyclage', 'is', null);

  if (error) return json({ ok: false, error: error.message }, 500);

  const cooldownMs = COOLDOWN_DAYS * 24 * 3600 * 1000;
  const nowMs = Date.now();

  // Regroupe les formateurs à notifier par centre.
  const byCenter = new Map<string, {
    center: { id: string, nom: string, email: string },
    items: { id: string, prenom: string, nom: string, niveau: string | null, state: State, due: Date | null }[]
  }>();

  for (const f of (formateurs || []) as any[]) {
    const { state, due } = computeState(f.date_dernier_recyclage);
    if (state === 'ok') continue;

    const prev = f.recyclage_alert_state;
    const lastSent = f.recyclage_alert_sent_at ? new Date(f.recyclage_alert_sent_at).getTime() : 0;
    const stale = nowMs - lastSent > cooldownMs;
    const stateChanged = prev !== state;
    if (!stateChanged && !stale) continue;

    const c = f.centers;
    if (!c || !c.email) continue;

    if (!byCenter.has(c.id)) byCenter.set(c.id, { center: c, items: [] });
    byCenter.get(c.id)!.items.push({
      id: f.id, prenom: f.prenom, nom: f.nom, niveau: f.niveau, state, due
    });
  }

  const summary: any[] = [];
  for (const { center, items } of byCenter.values()) {
    const subject = buildSubject(items);
    const html = buildHtml(center.nom, items);

    let sent = false;
    let detail: any = {};

    if (dryRun) {
      detail = { dry_run: true };
    } else if (!MAILGUN_API_KEY) {
      detail = { sent: false, reason: 'no_mailgun_key' };
    } else {
      try {
        const form = new FormData();
        form.append('from', MAILGUN_FROM);
        form.append('to', center.email);
        form.append('subject', subject);
        form.append('html', html);
        const r = await fetch(`https://${MAILGUN_HOST}/v3/${MAILGUN_DOMAIN}/messages`, {
          method: 'POST',
          headers: { 'Authorization': `Basic ${btoa(`api:${MAILGUN_API_KEY}`)}` },
          body: form
        });
        const txt = await r.text();
        sent = r.ok;
        detail = { sent, status: r.status, body: txt.slice(0, 300) };
      } catch (e) {
        detail = { sent: false, error: String((e as any)?.message || e) };
      }
    }

    if (sent) {
      const nowIso = new Date().toISOString();
      for (const it of items) {
        await admin.from('formateurs').update({
          recyclage_alert_state: it.state,
          recyclage_alert_sent_at: nowIso
        }).eq('id', it.id);
      }
    }

    summary.push({
      center_id: center.id, center_nom: center.nom, recipient: center.email,
      formateurs: items.length, subject, ...detail
    });
  }

  return json({ ok: true, dry_run: dryRun, centers_notified: summary.length, summary });
});

function buildSubject(items: { state: State }[]) {
  const exp = items.filter(i => i.state === 'expired').length;
  const soon = items.filter(i => i.state === 'soon').length;
  const parts = [];
  if (exp) parts.push(`${exp} recyclage(s) expiré(s)`);
  if (soon) parts.push(`${soon} à recycler bientôt`);
  return `[MIB] Formateurs : ${parts.join(' — ')}`;
}

function buildHtml(centerName: string, items: { prenom: string, nom: string, niveau: string | null, state: State, due: Date | null }[]) {
  const fmt = (d: Date | null) => d ? d.toLocaleDateString('fr-FR') : '—';
  const line = (i: typeof items[number]) => {
    const niv = i.niveau ? ` (${i.niveau})` : '';
    if (i.state === 'expired') {
      return `<li style="color:#b91c1c;"><strong>${escapeHtml(i.prenom)} ${escapeHtml(i.nom)}</strong>${escapeHtml(niv)} — <strong>recyclage expiré</strong> depuis le ${fmt(i.due)}.</li>`;
    }
    return `<li style="color:#c2410c;"><strong>${escapeHtml(i.prenom)} ${escapeHtml(i.nom)}</strong>${escapeHtml(niv)} — à recycler avant le <strong>${fmt(i.due)}</strong>.</li>`;
  };
  return `<div style="font-family:Arial,sans-serif;max-width:600px;">
    <h2 style="color:#065f46;">Recyclage SSIAP — ${escapeHtml(centerName)}</h2>
    <p>Bonjour,</p>
    <p>Le suivi automatique a détecté ${items.length} formateur(s) concerné(s) par le recyclage SSIAP des 3 ans :</p>
    <ul>${items.map(line).join('')}</ul>
    <p>Connectez-vous à votre espace centre pour mettre à jour la date du dernier recyclage de chaque formateur concerné.</p>
    <p style="color:#6b7280;font-size:.85rem;">Vous recevez ce message car vous êtes le contact de ce centre dans MIB Prévention.</p>
  </div>`;
}

function json(obj: unknown, status = 200) {
  return new Response(JSON.stringify(obj), { status, headers: { ...cors, 'Content-Type': 'application/json' } });
}

function escapeHtml(s: string) {
  return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}
