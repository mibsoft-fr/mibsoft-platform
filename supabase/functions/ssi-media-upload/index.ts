const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-path, x-content-type, x-bucket',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}
function json(o: unknown, s: number) {
  return new Response(JSON.stringify(o), { status: s, headers: { ...CORS, 'Content-Type': 'application/json' } })
}
const BUCKETS = new Set(['ssi-plan-media', 'ssi-plans'])

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS })
  if (req.method !== 'POST') return json({ error: 'METHOD' }, 405)
  const URL = Deno.env.get('SUPABASE_URL')!
  const SR = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  try {
    const jwt = (req.headers.get('Authorization') || '').replace(/^Bearer\s+/i, '')
    if (!jwt) return json({ error: 'NO_TOKEN' }, 401)

    const ures = await fetch(`${URL}/auth/v1/user`, { headers: { Authorization: `Bearer ${jwt}`, apikey: SR } })
    if (!ures.ok) return json({ error: 'INVALID_TOKEN' }, 401)
    const user = await ures.json()
    const uid = user?.id
    const email = user?.email || ''
    if (!uid) return json({ error: 'INVALID_TOKEN' }, 401)

    const bucket = req.headers.get('x-bucket') || 'ssi-plan-media'
    if (!BUCKETS.has(bucket)) return json({ error: 'BAD_BUCKET', bucket }, 400)
    const path = req.headers.get('x-path') || ''
    if (!path || path.includes('..') || path.startsWith('/')) return json({ error: 'BAD_PATH', path }, 400)
    const scope = path.split('/')[0]

    // Autorisation selon le scope (1er segment) : 'shared' => super-admin ; sinon centre/formateur du centre.
    const q = async (p: string) => {
      const r = await fetch(`${URL}/rest/v1/${p}`, { headers: { apikey: SR, Authorization: `Bearer ${SR}` } })
      return r.ok ? await r.json() : []
    }
    const sa = (await q(`super_admins?auth_user_id=eq.${uid}&select=auth_user_id`)).length > 0
    let allowed = false
    if (scope === 'shared') allowed = sa
    else if (sa) allowed = true
    else {
      const c = (await q(`centers?auth_user_id=eq.${uid}&id=eq.${scope}&select=id`)).length > 0
      const f = c ? true : (await q(`formateurs?auth_user_id=eq.${uid}&center_id=eq.${scope}&select=id`)).length > 0
      allowed = c || f
    }
    if (!allowed) return json({ error: scope === 'shared' ? 'NOT_SUPER_ADMIN' : 'NOT_ALLOWED_FOR_SCOPE', email, sa }, 403)

    const ct = req.headers.get('x-content-type') || req.headers.get('content-type') || 'application/octet-stream'
    const body = await req.arrayBuffer()
    if (!body.byteLength) return json({ error: 'EMPTY_BODY' }, 400)
    const enc = path.split('/').map(encodeURIComponent).join('/')
    const up = await fetch(`${URL}/storage/v1/object/${bucket}/${enc}`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${SR}`, apikey: SR, 'Content-Type': ct, 'x-upsert': 'true' },
      body,
    })
    if (!up.ok) { let m = ''; try { m = (await up.json()).message || '' } catch (_) {} return json({ error: m || ('STORAGE ' + up.status), email }, 400) }
    return json({ ok: true, email, sa, url: `${URL}/storage/v1/object/public/${bucket}/${enc}` }, 200)
  } catch (e) {
    return json({ error: (e && (e as Error).message) || String(e) }, 500)
  }
})
