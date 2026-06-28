// ============================================================
// supabase.js — Configuration partagée MIBsoft Platform
// À inclure en premier dans chaque page HTML :
// <script src="supabase.js"></script>
// ============================================================

// SDK Supabase (à inclure avant ce fichier dans le HTML) :
// <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"></script>

// ── Sélection automatique du projet selon le domaine ───────────────────────
// PRODUCTION (mibsoft.fr, www. et app.mibsoft.fr) → base PROD.
// Tout le reste (previews Vercel *.vercel.app, localhost, IP) → base DEV/test.
// Les clés « anon » sont des clés PUBLIQUES par conception (RLS protège les données) :
// il est normal et sûr de les exposer dans le front.
const SUPABASE_PROJECTS = {
  prod: {
    url: 'https://vsddtohdkcwihlybfief.supabase.co',
    anon: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZzZGR0b2hka2N3aWhseWJmaWVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI0MTgxMDUsImV4cCI6MjA5Nzk5NDEwNX0.bP6YT7GF7rqbfjJPWuSCyglsTFrvLUWg9PXL1U7PJKE'
  },
  dev: {
    url: 'https://ozfkmlokovxigfnwjeuk.supabase.co',
    anon: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im96ZmttbG9rb3Z4aWdmbndqZXVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1ODUzODUsImV4cCI6MjA5MTE2MTM4NX0.zu5V20Nz7vO3dSYhOtr7mqS7VAMaUDVS2Ibs01xS9Fk'
  }
};
// mibsoft.fr / www.mibsoft.fr / app.mibsoft.fr (et sous-domaines mibsoft.fr) → prod.
const _mibHost = (typeof window !== 'undefined' && window.location && window.location.hostname || '').toLowerCase();
const _isMibProd = /(^|\.)mibsoft\.fr$/.test(_mibHost);
const _mibEnv = _isMibProd ? SUPABASE_PROJECTS.prod : SUPABASE_PROJECTS.dev;
const SUPABASE_URL = _mibEnv.url;
const SUPABASE_ANON_KEY = _mibEnv.anon;

// Client Supabase global — utilisé partout
// On réaffecte window.supabase pour éviter le conflit CDN
window.supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
    // Verrou d'auth PAR ONGLET (au lieu du navigator.locks global) : quand plusieurs onglets MIB
    // sont ouverts, un onglet en arrière-plan throttlé par Chrome pouvait bloquer le rafraîchissement
    // du token des autres → page ouverte longtemps = « perte de connexion », données qui ne chargent
    // plus, publication NOT_SUPER_ADMIN. Ce verrou sérialise quand même les refresh À L'INTÉRIEUR de
    // l'onglet, sans jamais bloquer entre onglets.
    lock: (() => { let p = Promise.resolve(); return (_name, _timeout, fn) => { const run = p.then(fn, fn); p = run.then(() => {}, () => {}); return run; }; })()
  },
  realtime: {
    params: { eventsPerSecond: 10 }
  }
});

// ── Garde-session ──────────────────────────────────────────────────────────
// Maintient le token frais même si l'onglet reste ouvert très longtemps ou en arrière-plan : les
// timers d'auto-refresh sont throttlés/suspendus par Chrome en arrière-plan, donc le token finissait
// par expirer (≈1 h) et il fallait se reconnecter. On rafraîchit de façon PROACTIVE — au retour sur
// l'onglet, au retour réseau, et périodiquement — AVANT l'expiration. Plus besoin de se reconnecter.
if (typeof window !== 'undefined') {
  let _keeperBusy = false;
  const keepSession = async (force) => {
    if (_keeperBusy) return;
    _keeperBusy = true;
    try {
      // getSession() lit la session du client courant (clé de stockage du rôle, pas une clé en dur).
      const { data } = await supabase.auth.getSession();
      const s = data && data.session;
      if (!s || !s.access_token) return;               // pas connecté : rien à faire
      const exp = s.expires_at || 0;
      const now = Math.floor(Date.now() / 1000);
      if (!force && exp - now > 600) return;            // encore > 10 min de validité : on laisse
      await Promise.race([
        supabase.auth.refreshSession().catch(() => {}),
        new Promise(r => setTimeout(r, 8000))           // garde-fou anti-blocage
      ]);
    } catch (_) { /* ignore */ } finally { _keeperBusy = false; }
  };
  document.addEventListener('visibilitychange', () => { if (document.visibilityState === 'visible') keepSession(false); });
  window.addEventListener('focus', () => keepSession(false));
  window.addEventListener('online', () => keepSession(true));
  setInterval(() => keepSession(false), 4 * 60 * 1000); // filet de sécurité toutes les 4 min
  // Exposé pour forcer un rafraîchissement juste avant une action sensible (publication, etc.).
  window.MIBKeepSession = keepSession;
}



// ============================================================
// STORAGE — URLs publiques
// ============================================================
const STORAGE = {
  videos:    `${SUPABASE_URL}/storage/v1/object/public/videos`,
  photos:    `${SUPABASE_URL}/storage/v1/object/public/photos`,
  documents: `${SUPABASE_URL}/storage/v1/object/public/documents`,

  // Construire une URL complète depuis un chemin relatif
  url: (bucket, path) => `${SUPABASE_URL}/storage/v1/object/public/${bucket}/${path}`,

  // Uploader un fichier
  upload: async (bucket, path, file) => {
    const { data, error } = await supabase.storage
      .from(bucket)
      .upload(path, file, { upsert: true });
    if (error) throw error;
    return STORAGE.url(bucket, data.path);
  }
};

// Upload fiable via l'Edge Function (clé service_role, contourne la RLS Storage).
// Vérifie les droits côté serveur (super-admin pour « shared/ », centre/formateur pour son scope).
// IMPORTANT : on rafraîchit le token AVANT l'appel s'il est expiré/proche de l'expiration, sinon le
// serveur reçoit un JWT périmé qui a perdu le claim super-admin → NOT_SUPER_ADMIN + impression de
// « perte de connexion » au bout d'~1 h. Renvoie {ok:true,url} ou {error}.
async function edgeUploadObject(bucket, path, blobOrFile, contentType) {
  // Lit la session du CLIENT COURANT (via getSession), pas une clé localStorage en dur : ainsi on
  // envoie toujours le bon token, même quand une page utilise une clé de stockage dédiée (ex. admin
  // super-admin isolé du centre/formateur) — sinon un onglet d'un autre rôle « écrasait » la session
  // partagée et le serveur recevait un token non-super-admin → NOT_SUPER_ADMIN.
  const readTok = async () => {
    try {
      const { data } = await supabase.auth.getSession();
      const s = data && data.session;
      const at = s && s.access_token;
      if (!at) return null;
      return { token: at, exp: s.expires_at || 0 };
    } catch (_) { return null; }
  };
  // Rafraîchit la session sans risque de blocage multi-onglets (course navigator.locks) : timeout 8 s.
  const refresh = () => Promise.race([
    supabase.auth.refreshSession().catch(() => {}),
    new Promise(r => setTimeout(r, 8000))
  ]);
  const send = async (token) => {
    const ctrl = new AbortController(); const to = setTimeout(() => ctrl.abort(), 45000);
    try {
      const res = await fetch(SUPABASE_URL + '/functions/v1/ssi-media-upload', {
        method: 'POST',
        headers: {
          'Authorization': 'Bearer ' + token,
          'apikey': SUPABASE_ANON_KEY,
          'x-bucket': bucket,
          'x-path': path,
          'x-content-type': contentType || 'application/octet-stream'
        },
        body: blobOrFile, signal: ctrl.signal
      });
      let j = {}; try { j = await res.json(); } catch (_) {}
      return { status: res.status, ok: res.ok && j && j.ok, j };
    } catch (e) {
      return { status: 0, ok: false, j: { error: (e && e.name === 'AbortError') ? 'délai dépassé' : ((e && e.message) || (e + '')) } };
    } finally { clearTimeout(to); }
  };

  let tk = await readTok();
  const now = Math.floor(Date.now() / 1000);
  // Token absent ou expirant dans < 120 s : on rafraîchit AVANT l'appel.
  if (!tk || !tk.exp || tk.exp - now < 120) { await refresh(); tk = (await readTok()) || tk; }
  if (!tk || !tk.token) return { error: 'NO_SESSION' };

  let r = await send(tk.token);
  if (r.ok) return { ok: true, url: r.j.url };
  // Reprise unique : si le serveur refuse pour cause d'authentification (token périmé / claim manquant),
  // on force un refresh et on réessaie avec le nouveau token.
  const e = (r.j && r.j.error) || '';
  const authish = r.status === 401 || /jwt|expir|token|NOT_SUPER_ADMIN|NOT_ALLOWED/i.test(e);
  if (authish) {
    await refresh();
    const t2 = await readTok();
    if (t2 && t2.token && t2.token !== tk.token) {
      r = await send(t2.token);
      if (r.ok) return { ok: true, url: r.j.url };
    }
  }
  return { error: (r.j && r.j.error) || ('HTTP ' + r.status) };
}

// ============================================================
// HELPERS — Requêtes Supabase simplifiées
// ============================================================
const DB = {

  // SELECT
  get: async (table, filters = {}) => {
    let query = supabase.from(table).select('*');
    Object.entries(filters).forEach(([col, val]) => {
      query = query.eq(col, val);
    });
    const { data, error } = await query;
    if (error) throw error;
    return data;
  },

  // SELECT avec filtre avancé (fonction callback)
  query: async (table, builderFn) => {
    const base = supabase.from(table).select('*');
    const { data, error } = await builderFn(base);
    if (error) throw error;
    return data;
  },

  // INSERT
  insert: async (table, payload) => {
    const { data, error } = await supabase
      .from(table)
      .insert(payload)
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  // UPDATE
  update: async (table, id, payload) => {
    const { data, error } = await supabase
      .from(table)
      .update({ ...payload, updated_at: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  // UPDATE sans champ updated_at (tables sans ce champ)
  updateSimple: async (table, id, payload) => {
    const { data, error } = await supabase
      .from(table)
      .update(payload)
      .eq('id', id)
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  // DELETE
  delete: async (table, id) => {
    const { error } = await supabase
      .from(table)
      .delete()
      .eq('id', id);
    if (error) throw error;
  },

  // SELECT par ID
  getById: async (table, id) => {
    const { data, error } = await supabase
      .from(table)
      .select('*')
      .eq('id', id)
      .single();
    if (error) throw error;
    return data;
  }
};

// ============================================================
// REALTIME — Remplace Firebase .on('value') et .on('child_added')
// ============================================================
const REALTIME = {

  // Écouter les changements sur une table filtrée par colonne
  // Remplace : db.ref('sessions/xxx').on('value', ...)
  subscribe: (channelName, table, filter, callback) => {
    const channel = supabase
      .channel(channelName)
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table, filter },
        (payload) => callback(payload)
      )
      .subscribe();
    return channel; // garder la référence pour se désabonner
  },

  // Écouter uniquement les INSERT (équivalent child_added Firebase)
  subscribeInsert: (channelName, table, filter, callback) => {
    const channel = supabase
      .channel(channelName)
      .on(
        'postgres_changes',
        { event: 'INSERT', schema: 'public', table, filter },
        (payload) => callback(payload.new)
      )
      .subscribe();
    return channel;
  },

  // Écouter uniquement les UPDATE
  subscribeUpdate: (channelName, table, filter, callback) => {
    const channel = supabase
      .channel(channelName)
      .on(
        'postgres_changes',
        { event: 'UPDATE', schema: 'public', table, filter },
        (payload) => callback(payload.new, payload.old)
      )
      .subscribe();
    return channel;
  },

  // Broadcast — temps réel sans écriture en base
  // Idéal pour signalisation WebRTC (offer/answer/ICE)
  broadcast: (channelName) => {
    return supabase.channel(channelName, {
      config: { broadcast: { self: false } }
    });
  },

  // Se désabonner proprement
  // Remplace : ref.off() de Firebase
  unsubscribe: async (channel) => {
    if (channel) await supabase.removeChannel(channel);
  },

  // Se désabonner de tous les canaux
  unsubscribeAll: async () => {
    await supabase.removeAllChannels();
  }
};

// ============================================================
// SESSION — Gestion de l'état de connexion local
// ============================================================
const SESSION = {

  // Sauvegarder la session dans localStorage
  save: (key, data) => {
    localStorage.setItem(`mib_${key}`, JSON.stringify({
      ...data,
      savedAt: new Date().toISOString()
    }));
  },

  // Récupérer une session sauvegardée
  load: (key) => {
    try {
      const raw = localStorage.getItem(`mib_${key}`);
      return raw ? JSON.parse(raw) : null;
    } catch { return null; }
  },

  // Supprimer une session
  clear: (key) => localStorage.removeItem(`mib_${key}`),

  // Supprimer toutes les sessions MIB
  clearAll: () => {
    Object.keys(localStorage)
      .filter(k => k.startsWith('mib_'))
      .forEach(k => localStorage.removeItem(k));
  }
};

// ============================================================
// UTILS — Fonctions partagées
// ============================================================
const UTILS = {

  // Générer un UUID
  uuid: () => crypto.randomUUID(),

  // Générer un numéro de session horodaté
  sessionNumber: () => {
    const now = new Date();
    return now.getFullYear().toString()
      + String(now.getMonth() + 1).padStart(2, '0')
      + String(now.getDate()).padStart(2, '0')
      + String(now.getHours()).padStart(2, '0')
      + String(now.getMinutes()).padStart(2, '0')
      + String(now.getSeconds()).padStart(2, '0');
  },

  // Hasher un mot de passe / PIN avec SHA-256 (côté client)
  hash: async (text) => {
    const encoder = new TextEncoder();
    const data = encoder.encode(text);
    const hashBuffer = await crypto.subtle.digest('SHA-256', data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  },

  // Mélanger un tableau
  shuffle: (arr) => {
    const a = [...arr];
    for (let i = a.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [a[i], a[j]] = [a[j], a[i]];
    }
    return a;
  },

  // Formater une date en français
  dateStr: (date) => new Date(date).toLocaleDateString('fr-FR', {
    day: '2-digit', month: '2-digit', year: 'numeric'
  }),

  // Formater une durée en secondes → 'Xm Xs'
  duration: (seconds) => {
    if (!seconds) return '—';
    const m = Math.floor(seconds / 60);
    const s = seconds % 60;
    return m > 0 ? `${m}m ${s}s` : `${s}s`;
  }
};

// ============================================================
// MODULES — Vérifier si un module est actif pour un centre
// ============================================================
const MODULES = {
  check: (center, moduleName) => {
    if (!center) return false;
    return center[`module_${moduleName}`] === true;
  },

  // Noms des modules
  AUTOFORMATION:    'auto_entrainement',
  QUIZ_SALLE:       'quiz_salle',
  CHALLENGE_CUP:    'challenge_cup',
  SSI_SUPERVISE:    'ssi_supervise',
  SSI_AUTOFORMATION:'ssi_autoformation'
};

// ============================================================
// MIBLog — Helper de log applicatif (insère dans app_logs)
// ============================================================
const MIBLog = {
  _src: (typeof window !== 'undefined' && window.location ? (window.location.pathname.split('/').pop() || 'index').replace('.html','') : 'unknown'),
  _ctx: () => {
    const ctx = {};
    try {
      const f = JSON.parse(localStorage.getItem('mib_formateur') || 'null');
      const s = JSON.parse(localStorage.getItem('mib_stagiaire') || 'null');
      const c = JSON.parse(localStorage.getItem('mib_centre')    || 'null');
      if (f && f.formateur_id) { ctx.user_role = 'formateur'; ctx.center_id = f.center_id; }
      else if (s && s.stagiaire_id) { ctx.user_role = 'stagiaire'; ctx.center_id = s.center_id; }
      else if (c && c.center_id) { ctx.user_role = 'centre'; ctx.center_id = c.center_id; }
    } catch(_) {}
    return ctx;
  },
  _post: async (level, message, context) => {
    try {
      const baseCtx = MIBLog._ctx();
      let user_id = null;
      try { const { data } = await supabase.auth.getUser(); user_id = data?.user?.id || null; } catch(_) {}
      await supabase.from('app_logs').insert({
        level, source: MIBLog._src, message: String(message).slice(0, 1000),
        center_id: baseCtx.center_id || null,
        user_role: baseCtx.user_role || null,
        user_id,
        context: context ? JSON.parse(JSON.stringify(context)) : null,
        user_agent: navigator.userAgent.slice(0, 250)
      });
    } catch(_) { /* fail silently — pas de boucle d'erreurs */ }
  },
  info:  (msg, ctx) => MIBLog._post('info',  msg, ctx),
  warn:  (msg, ctx) => MIBLog._post('warn',  msg, ctx),
  error: (msg, ctx) => MIBLog._post('error', msg, ctx),
  debug: (msg, ctx) => MIBLog._post('debug', msg, ctx)
};

// Capture automatique des erreurs JS non gérées (toutes pages qui chargent supabase.js).
// Anti-flood : une même erreur n'est journalisée qu'une fois par minute, sinon une erreur
// récurrente (ex. boucle de rendu, ressource externe qui échoue) remplit app_logs et fait
// dépasser les seuils du monitoring (« X erreurs en 5 min ») → alertes mail/SMS en rafale.
if (typeof window !== 'undefined') {
  const _errSeen = new Map();
  const _shouldLog = (key) => {
    const now = Date.now();
    const last = _errSeen.get(key) || 0;
    if (now - last < 60000) return false;          // même message : 1 log / minute max
    _errSeen.set(key, now);
    if (_errSeen.size > 50) _errSeen.clear();        // garde la map petite
    return true;
  };
  window.addEventListener('error', (e) => {
    const msg = e.message || 'window.error';
    if (!_shouldLog(msg)) return;
    MIBLog.error(msg, { filename: e.filename, lineno: e.lineno, colno: e.colno, stack: e.error?.stack?.slice(0, 500) });
  });
  window.addEventListener('unhandledrejection', (e) => {
    const msg = 'unhandledrejection: ' + (e.reason?.message || e.reason || 'unknown');
    if (!_shouldLog(msg)) return;
    MIBLog.error(msg, { stack: e.reason?.stack?.slice(0, 500) });
  });
}

console.log('✅ MIBsoft Platform — Supabase initialisé');
console.log(`📡 Projet : ${SUPABASE_URL} (${_isMibProd ? 'PROD' : 'DEV/test'})`);
