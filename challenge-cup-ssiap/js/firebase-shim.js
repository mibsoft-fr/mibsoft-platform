// =====================================================================
// Firebase Realtime DB shim, backed by Supabase.
// Drop-in replacement for the firebase-app-compat + firebase-database-compat
// scripts: it exposes window.firebase and window.firebase.database() with
// the methods the legacy index.html actually uses.
//
// Path conventions (kept identical to the original Firebase tree):
//   sessions/{code}
//   sessions/{code}/teams/{teamId}
//   sessions/{code}/teams/{teamId}/<field>
//   sessions/{code}/logs/{logId}
//   sessions/{code}/<field>     (status, currentBox, gameStatus, ...)
// =====================================================================

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = 'https://uojhwuwplpodgnwvwvmm.supabase.co';
const SUPABASE_KEY = 'sb_publishable_D0J8NNAGuXqy0u1lQ2qqhg_WZrLAzWk';

const sb = createClient(SUPABASE_URL, SUPABASE_KEY, {
  auth: { persistSession: false },
  realtime: { params: { eventsPerSecond: 10 } },
});

// ---------- Field-name mapping (Firebase ↔ Supabase) ----------------

const SESSION_F2S = {
  status:           'status',
  currentBox:       'current_box_idx',
  currentGameIndex: 'current_q_idx',
  gameStatus:       'game_status',
  ssiapLevel:       'level',
  openedBoxes:      'opened_modules',
  randomizedGames:  'randomized_games',
  currentGame:      'current_game',
  answersCount:     'answers_count',
  questionTimestamp:'question_started_at',
  createdAt:        'created_at',
};
const SESSION_S2F = invert(SESSION_F2S);

const TEAM_F2S = {
  name:             'name',
  avatar:           'avatar',
  score:            'score',
  hasAnswered:      'has_answered',
  isCorrect:        'current_is_correct',
  answer:           'current_answer',
  answerTime:       'answer_time',
  online:           'online',
  totalCorrect:     'total_correct',
  totalAnswered:    'total_answered',
  lastPoints:       'last_points',
  lastSpeedBonus:   'last_speed_bonus',
  lastOfflineLog:   'last_offline_log',
  joinedAt:         'joined_at',
};
const TEAM_S2F = invert(TEAM_F2S);

function invert(obj) { return Object.fromEntries(Object.entries(obj).map(([k,v])=>[v,k])); }
function mapKeys(obj, map) {
  if (!obj || typeof obj !== 'object') return obj;
  const out = {};
  for (const [k,v] of Object.entries(obj)) out[map[k] ?? k] = v;
  return out;
}
function f2sSession(obj) {
  // Convert questionTimestamp from epoch ms to ISO if present
  const o = { ...obj };
  if ('questionTimestamp' in o && typeof o.questionTimestamp === 'number') {
    o.questionTimestamp = new Date(o.questionTimestamp).toISOString();
  }
  return mapKeys(o, SESSION_F2S);
}
function s2fSession(row) {
  if (!row) return row;
  const o = mapKeys(row, SESSION_S2F);
  // teams sub-tree is loaded lazily; consumers read via separate paths.
  return o;
}
// Allowed Supabase columns on `teams`. Anything else from the legacy payload
// (e.g. `answerTime`) is dropped silently to avoid 4xx from PostgREST.
const TEAM_COLUMNS = new Set([
  'id','session_id','name','avatar','score','total_correct','total_answered',
  'has_answered','online','joined_at','last_seen_at','current_answer',
  'current_is_correct','last_points','last_speed_bonus','last_offline_log',
  'answer_time',
]);
const TEAM_TS_COLUMNS = new Set(['joined_at','last_seen_at','last_offline_log']);

function f2sTeam(obj) {
  const renamed = mapKeys(obj, TEAM_F2S);
  const out = {};
  for (const [k, v] of Object.entries(renamed)) {
    if (!TEAM_COLUMNS.has(k)) continue;
    if (TEAM_TS_COLUMNS.has(k) && typeof v === 'number') {
      out[k] = new Date(v).toISOString();
    } else {
      out[k] = v;
    }
  }
  return out;
}
function s2fTeam(row) {
  if (!row) return row;
  const o = mapKeys(row, TEAM_S2F);
  // Drop server-only fields the game doesn't read
  delete o.session_id;
  return o;
}

// ---------- Session-code → uuid lookup (cached) ---------------------

const codeToId = new Map();
async function sessionUuidByCode(code) {
  if (!code) return null;
  if (codeToId.has(code)) return codeToId.get(code);
  const { data } = await sb.from('sessions').select('id').eq('session_code', code).maybeSingle();
  if (data?.id) codeToId.set(code, data.id);
  return data?.id ?? null;
}

// Atomically create-or-lookup a session by its session_code. The legacy
// game calls `database.ref('sessions/'+sid).set({...})` to create one, so we
// translate to insert-or-upsert by session_code.
async function ensureSessionRow(code, payload) {
  const fields = f2sSession(payload);
  const row = {
    session_code: code,
    level:        fields.level ?? 1,
    status:       fields.status ?? 'waiting',
    game_status:  fields.game_status ?? 'waiting',
    current_box_idx: fields.current_box_idx ?? -1,
    current_q_idx:   fields.current_q_idx ?? 0,
    opened_modules:  fields.opened_modules ?? [],
    answers_count:   fields.answers_count ?? 0,
  };
  const { data, error } = await sb.from('sessions')
    .upsert(row, { onConflict: 'session_code' })
    .select()
    .single();
  if (error) throw error;
  codeToId.set(code, data.id);
  return data;
}

// ---------- Path parsing -------------------------------------------

// Parses a Firebase path (e.g. "sessions/ABCDEF/teams/<uuid>/score")
// into a structured op descriptor.
function parsePath(path) {
  const segs = (path || '').split('/').filter(Boolean);
  // sessions/{code}[/{...}]
  if (segs[0] !== 'sessions' || !segs[1]) {
    return { kind: 'unknown', segs };
  }
  const code = segs[1];
  if (segs.length === 2) return { kind: 'session', code };
  const sub = segs[2];
  if (sub === 'teams') {
    if (segs.length === 3) return { kind: 'teams', code };
    const teamId = segs[3];
    if (segs.length === 4) return { kind: 'team', code, teamId };
    const field = segs.slice(4).join('/');
    return { kind: 'team-field', code, teamId, field };
  }
  if (sub === 'logs') {
    if (segs.length === 3) return { kind: 'logs', code };
    return { kind: 'log', code, logId: segs[3] };
  }
  // sessions/{code}/<field>
  return { kind: 'session-field', code, field: segs.slice(2).join('/') };
}

// ---------- Realtime listener registry -----------------------------

// Each path tracks the last broadcast value so we can suppress callbacks
// fired by unrelated changes on the same row (e.g. answers_count bumping
// shouldn't re-trigger a gameStatus listener and re-show the question).
const channels = new Map(); // path -> { channel, callbacks: Set, lastValue }

function deepEqual(a, b) {
  if (a === b) return true;
  if (a == null || b == null) return a === b;
  if (typeof a !== typeof b) return false;
  if (typeof a !== 'object') return false;
  if (Array.isArray(a) !== Array.isArray(b)) return false;
  const ka = Object.keys(a), kb = Object.keys(b);
  if (ka.length !== kb.length) return false;
  for (const k of ka) if (!deepEqual(a[k], b[k])) return false;
  return true;
}

function broadcast(path, val, exists) {
  const reg = channels.get(path);
  if (!reg) return;
  if ('lastValue' in reg && deepEqual(reg.lastValue, val)) return;
  reg.lastValue = val;
  for (const cb of reg.callbacks) {
    try { cb(makeSnapshot(val, exists)); } catch (e) { console.error('[shim] cb error', e); }
  }
}

function makeSnapshot(value, existsBool) {
  return {
    val: () => value,
    exists: () => existsBool ?? value != null,
    forEach: (fn) => {
      if (value && typeof value === 'object') {
        for (const [k, v] of Object.entries(value)) {
          fn({ key: k, val: () => v });
        }
      }
    },
    key: null,
  };
}

// Subscribe to a path. Implemented per (path-kind, code).
async function subscribe(path, callback) {
  const op = parsePath(path);
  const reg = channels.get(path) ?? { callbacks: new Set(), channel: null };
  reg.callbacks.add(callback);
  channels.set(path, reg);

  // Initial value via once() — establishes the baseline for change detection.
  const initial = await readPath(path);
  reg.lastValue = initial.value;
  callback(makeSnapshot(initial.value, initial.exists));

  if (reg.channel) return reg;
  if (op.kind === 'unknown') return reg;

  const sessionUuid = await sessionUuidByCode(op.code);
  if (!sessionUuid) return reg;

  if (op.kind === 'teams') {
    reg.channel = sb.channel(`teams:${sessionUuid}`)
      .on('postgres_changes', { event: '*', schema: 'public', table: 'teams', filter: `session_id=eq.${sessionUuid}` },
        async () => {
          const v = await readPath(path);
          broadcast(path, v.value, v.exists);
        })
      .subscribe();
  } else if (op.kind === 'team' || op.kind === 'team-field') {
    reg.channel = sb.channel(`team:${op.teamId}:${op.field || ''}`)
      .on('postgres_changes', { event: '*', schema: 'public', table: 'teams', filter: `id=eq.${op.teamId}` },
        async () => {
          const v = await readPath(path);
          broadcast(path, v.value, v.exists);
        })
      .subscribe();
  } else if (op.kind === 'session' || op.kind === 'session-field') {
    reg.channel = sb.channel(`session:${sessionUuid}:${op.field || ''}`)
      .on('postgres_changes', { event: '*', schema: 'public', table: 'sessions', filter: `id=eq.${sessionUuid}` },
        async () => {
          const v = await readPath(path);
          broadcast(path, v.value, v.exists);
        })
      .subscribe();
  }
  return reg;
}

function unsubscribe(path, callback) {
  const reg = channels.get(path);
  if (!reg) return;
  if (callback) reg.callbacks.delete(callback);
  else reg.callbacks.clear();
  if (reg.callbacks.size === 0) {
    if (reg.channel) sb.removeChannel(reg.channel);
    channels.delete(path);
  }
}

// ---------- Read / write at a path ---------------------------------

async function readPath(path) {
  const op = parsePath(path);
  if (op.kind === 'unknown') return { value: null, exists: false };

  if (op.kind === 'session') {
    const { data } = await sb.from('sessions').select('*').eq('session_code', op.code).maybeSingle();
    if (!data) return { value: null, exists: false };
    const session = s2fSession(data);
    // Embed teams + logs to mimic Firebase tree
    const { data: tRows } = await sb.from('teams').select('*').eq('session_id', data.id);
    session.teams = Object.fromEntries((tRows ?? []).map(r => [r.id, s2fTeam(r)]));
    return { value: session, exists: true };
  }
  if (op.kind === 'session-field') {
    const col = SESSION_F2S[op.field] ?? op.field;
    const { data } = await sb.from('sessions').select(col).eq('session_code', op.code).maybeSingle();
    if (!data) return { value: null, exists: false };
    let v = data[col];
    if (op.field === 'questionTimestamp' && v) v = new Date(v).getTime();
    return { value: v, exists: v != null };
  }
  if (op.kind === 'teams') {
    const sid = await sessionUuidByCode(op.code);
    if (!sid) return { value: null, exists: false };
    const { data } = await sb.from('teams').select('*').eq('session_id', sid);
    const tree = Object.fromEntries((data ?? []).map(r => [r.id, s2fTeam(r)]));
    return { value: tree, exists: !!Object.keys(tree).length };
  }
  if (op.kind === 'team') {
    const { data } = await sb.from('teams').select('*').eq('id', op.teamId).maybeSingle();
    return { value: data ? s2fTeam(data) : null, exists: !!data };
  }
  if (op.kind === 'team-field') {
    const col = TEAM_F2S[op.field] ?? op.field;
    const { data } = await sb.from('teams').select(col).eq('id', op.teamId).maybeSingle();
    if (!data) return { value: null, exists: false };
    return { value: data[col], exists: data[col] != null };
  }
  if (op.kind === 'logs') {
    const sid = await sessionUuidByCode(op.code);
    if (!sid) return { value: null, exists: false };
    const { data } = await sb.from('logs').select('*').eq('session_id', sid).order('id');
    const tree = Object.fromEntries((data ?? []).map((r, i) => [`log${i}`, {
      ts: new Date(r.created_at).getTime(),
      time: new Date(r.created_at).toLocaleTimeString('fr-FR'),
      level: r.level, category: r.category, message: r.message,
      team: r.team_name, ...(r.metadata || {}),
    }]));
    return { value: tree, exists: !!Object.keys(tree).length };
  }
  return { value: null, exists: false };
}

async function writePath(path, value, mode /* 'set' | 'update' */) {
  const op = parsePath(path);

  if (op.kind === 'session') {
    if (mode === 'set') return ensureSessionRow(op.code, value);
    const sid = await sessionUuidByCode(op.code) ?? (await ensureSessionRow(op.code, value)).id;
    const fields = f2sSession(value);
    if (Object.keys(fields).length) await sb.from('sessions').update(fields).eq('id', sid);
    return;
  }
  if (op.kind === 'session-field') {
    let sid = await sessionUuidByCode(op.code);
    if (!sid) sid = (await ensureSessionRow(op.code, {})).id;
    const col = SESSION_F2S[op.field] ?? op.field;
    let v = value;
    if (op.field === 'questionTimestamp' && typeof v === 'number') v = new Date(v).toISOString();
    await sb.from('sessions').update({ [col]: v }).eq('id', sid);
    return;
  }
  if (op.kind === 'teams' && mode === 'set') {
    const sid = await sessionUuidByCode(op.code);
    if (!sid) return;
    // Replace the whole teams subtree: delete + reinsert
    await sb.from('teams').delete().eq('session_id', sid);
    if (value && typeof value === 'object') {
      const rows = Object.entries(value).map(([id, t]) => ({
        id, session_id: sid, ...f2sTeam(t),
      }));
      if (rows.length) await sb.from('teams').insert(rows);
    }
    return;
  }
  if (op.kind === 'team') {
    const sid = await sessionUuidByCode(op.code);
    if (!sid) return;
    const fields = f2sTeam(value || {});
    if (mode === 'set') {
      await sb.from('teams').upsert({ id: op.teamId, session_id: sid, ...fields });
    } else {
      await sb.from('teams').update(fields).eq('id', op.teamId);
    }
    return;
  }
  if (op.kind === 'team-field') {
    const col = TEAM_F2S[op.field] ?? op.field;
    if (!TEAM_COLUMNS.has(col)) return;  // drop unknown fields (e.g. legacy answerTime)
    let v = value;
    if (TEAM_TS_COLUMNS.has(col) && typeof v === 'number') v = new Date(v).toISOString();
    await sb.from('teams').update({ [col]: v }).eq('id', op.teamId);
    return;
  }
  if (op.kind === 'log') {
    const sid = await sessionUuidByCode(op.code);
    if (!sid) return;
    const v = value || {};
    const ALLOWED_LEVELS = new Set(['info','warn','error','success','debug']);
    const level = ALLOWED_LEVELS.has(v.level) ? v.level : 'info';
    await sb.from('logs').insert({
      session_id: sid, level, category: v.category, message: v.message,
      team_name: v.team || null, metadata: v,
    });
    return;
  }
}

async function removePath(path) {
  const op = parsePath(path);
  if (op.kind === 'session') {
    const sid = await sessionUuidByCode(op.code);
    if (sid) await sb.from('sessions').delete().eq('id', sid);
    codeToId.delete(op.code);
    return;
  }
  if (op.kind === 'team') {
    await sb.from('teams').delete().eq('id', op.teamId);
    return;
  }
  if (op.kind === 'logs') {
    const sid = await sessionUuidByCode(op.code);
    if (sid) await sb.from('logs').delete().eq('session_id', sid);
    return;
  }
}

// Multipath update: keys are full paths.
async function multiUpdate(updates) {
  // Group keys by entity (team, session) to batch updates.
  const teams = new Map();   // teamId -> { sid, fields }
  const sessions = new Map();// code -> fields
  for (const [k, v] of Object.entries(updates || {})) {
    const op = parsePath(k);
    if (op.kind === 'team-field') {
      const col = TEAM_F2S[op.field] ?? op.field;
      if (!TEAM_COLUMNS.has(col)) continue;  // drop unknown fields
      let val = v;
      if (TEAM_TS_COLUMNS.has(col) && typeof val === 'number') val = new Date(val).toISOString();
      const t = teams.get(op.teamId) ?? { code: op.code, fields: {} };
      t.fields[col] = val; teams.set(op.teamId, t);
    } else if (op.kind === 'session-field') {
      const col = SESSION_F2S[op.field] ?? op.field;
      const s = sessions.get(op.code) ?? {};
      let val = v;
      if (op.field === 'questionTimestamp' && typeof val === 'number') val = new Date(val).toISOString();
      s[col] = val; sessions.set(op.code, s);
    }
  }
  // Run all updates in parallel for snappier transitions.
  await Promise.all([
    ...[...teams.entries()].map(([tid, info]) =>
      sb.from('teams').update(info.fields).eq('id', tid)),
    ...[...sessions.entries()].map(async ([code, fields]) => {
      const sid = await sessionUuidByCode(code);
      if (sid) return sb.from('sessions').update(fields).eq('id', sid);
    }),
  ]);
}

// Increment a numeric field (for `.transaction(c => (c||0)+count)`).
async function incrementField(path, delta) {
  const op = parsePath(path);
  if (op.kind === 'session-field') {
    const sid = await sessionUuidByCode(op.code);
    if (!sid) return;
    const col = SESSION_F2S[op.field] ?? op.field;
    const { data } = await sb.from('sessions').select(col).eq('id', sid).maybeSingle();
    const cur = (data?.[col] ?? 0) + delta;
    await sb.from('sessions').update({ [col]: cur }).eq('id', sid);
  }
}

// ---------- Ref factory --------------------------------------------

function makeRef(path = '') {
  const ref = {
    _path: path,
    child: (sub) => makeRef(path ? `${path}/${sub}` : sub),
    set: async (val) => writePath(path, val, 'set'),
    update: async (val) => path ? writePath(path, val, 'update') : multiUpdate(val),
    remove: async () => removePath(path),
    once: async (eventType, cb) => {
      const r = await readPath(path);
      const snap = makeSnapshot(r.value, r.exists);
      if (typeof cb === 'function') cb(snap);
      return snap;
    },
    on: (eventType, cb) => {
      subscribe(path, cb);
      return cb;
    },
    off: (eventType, cb) => {
      unsubscribe(path, cb);
    },
    push: async (val) => {
      // For logs path: insert. For others: not commonly used in the legacy code.
      const op = parsePath(path);
      if (op.kind === 'logs') {
        await writePath(`${path}/__auto`, val, 'set');
      } else {
        const newId = crypto.randomUUID();
        await writePath(`${path}/${newId}`, val, 'set');
        return makeRef(`${path}/${newId}`);
      }
      return makeRef(path);
    },
    transaction: async (fn) => {
      const r = await readPath(path);
      const next = fn(r.value);
      if (next !== undefined) {
        if (typeof r.value === 'number' && typeof next === 'number') {
          await incrementField(path, next - (r.value || 0));
        } else {
          await writePath(path, next, 'set');
        }
      }
      return { committed: true, snapshot: makeSnapshot(next, next != null) };
    },
    onDisconnect: () => ({
      // No-op shim. The legacy code only uses set(false)/remove() on online flags.
      // Realistic offline detection happens via beforeunload + last_seen_at.
      set: async () => {},
      remove: async () => {},
    }),
  };
  return ref;
}

// ---------- Expose Firebase-compat API -----------------------------

const firebase = {
  apps: [],
  initializeApp: (_config) => {
    if (firebase.apps.length === 0) firebase.apps.push({});
  },
  database: () => ({
    ref: (path) => makeRef(path || ''),
  }),
};

window.firebase = firebase;

// Best-effort offline mark on tab close.
window.addEventListener('beforeunload', async () => {
  // The legacy code already updates online=false where it can; nothing to do here.
});

console.log('[firebase-shim] Supabase backend ready');
