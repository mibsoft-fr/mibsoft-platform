import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

// ─────────────────────────────────────────────────────────────────────────────
// Filet de sécurité RGPD pour les vidéos de débriefing (bucket `ssi-debriefs`).
//
// Le fonctionnement nominal : la vidéo est purgée côté client dès que le
// formateur se déconnecte de la session (formateurDisconnect()). Elle est
// conservée le temps du débriefing, au maximum la durée de la formation.
//
// Mais si le formateur ne se déconnecte jamais (onglet fermé brutalement,
// crash, perte réseau), la purge côté client ne se déclenche pas. Cette
// fonction est le filet de sécurité serveur : elle supprime physiquement
// tout objet plus vieux que MAX_AGE_HOURS, indépendamment de l'état du
// client. Aucune vidéo ne peut donc survivre au-delà de ce plafond.
//
// Déclenchée toutes les heures par pg_cron (via pg_net → cette fonction).
// ─────────────────────────────────────────────────────────────────────────────

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

const BUCKET = 'ssi-debriefs';
// Plafond absolu = durée maximale d'une journée de formation SSIAP (largement
// couverte par 24h). Au-delà, la vidéo est réputée orpheline et purgée.
const MAX_AGE_HOURS = Number(Deno.env.get('DEBRIEF_MAX_AGE_HOURS') || '24');

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS'
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, 'Content-Type': 'application/json' }
  });
}

// Parcours du bucket : les objets sont rangés sous un préfixe = id de session.
// On liste la racine (dossiers) puis les fichiers de chaque dossier, en
// récupérant leur created_at pour décider de la purge. Un fichier posé
// directement à la racine (id non nul) est aussi pris en compte.
async function collectExpired(
  admin: ReturnType<typeof createClient>,
  cutoffMs: number
): Promise<{ all: string[]; expired: string[] }> {
  const all: string[] = [];
  const expired: string[] = [];

  const consider = (path: string, entry: any) => {
    all.push(path);
    const created = entry?.created_at ? new Date(entry.created_at).getTime() : 0;
    // created=0 (date inconnue) ⇒ objet suspect/orphelin ⇒ on purge.
    if (!created || created < cutoffMs) expired.push(path);
  };

  const { data: roots, error } = await admin.storage.from(BUCKET).list('', { limit: 1000 });
  if (error) throw error;

  for (const entry of roots || []) {
    const isFolder = entry.id === null || entry.id === undefined;
    if (isFolder) {
      const { data: files } = await admin.storage.from(BUCKET).list(entry.name, { limit: 1000 });
      for (const f of files || []) {
        if (f.id) consider(`${entry.name}/${f.name}`, f);
      }
    } else {
      consider(entry.name, entry);
    }
  }
  return { all, expired };
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE);
  const cutoffMs = Date.now() - MAX_AGE_HOURS * 3600 * 1000;

  let body: any = {};
  try { body = await req.json(); } catch { body = {}; }
  const dryRun = body?.dry_run === true;

  let all: string[], expired: string[];
  try {
    ({ all, expired } = await collectExpired(admin, cutoffMs));
  } catch (e) {
    return json({ ok: false, error: (e as Error).message }, 500);
  }

  if (dryRun) {
    return json({ ok: true, dry_run: true, total: all.length, would_delete: expired });
  }

  let removed = 0;
  // remove() par lots de 100 pour rester sous les limites de l'API storage.
  for (let i = 0; i < expired.length; i += 100) {
    const batch = expired.slice(i, i + 100);
    const { error } = await admin.storage.from(BUCKET).remove(batch);
    if (!error) removed += batch.length;
  }

  return json({ ok: true, total: all.length, removed, cutoff_hours: MAX_AGE_HOURS });
});
