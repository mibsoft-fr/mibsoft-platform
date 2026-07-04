import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Content-Type": "application/json",
};

function err(status: number, code: string, msg: string) {
  return new Response(JSON.stringify({ error: code, message: msg }), { status, headers: CORS });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: CORS });
  if (req.method !== "POST") return err(405, "method", "POST only");

  let body: { email?: string; license_key?: string; password?: string };
  try { body = await req.json(); } catch { return err(400, "bad_json", "Invalid JSON"); }

  const email = (body.email || "").trim().toLowerCase();
  const license_key = (body.license_key || "").trim().toUpperCase();
  const password = body.password || "";

  if (!email || !license_key || !password) return err(400, "missing", "email, license_key, password requis");
  if (password.length < 8) return err(400, "weak", "Mot de passe trop court (min 8)");
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) return err(400, "bad_email", "Email invalide");

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE, { auth: { persistSession: false } });

  const { data: centre, error: cErr } = await admin
    .from("centers")
    .select("id, nom, license_status, license_expires_at, password_set, auth_user_id")
    .eq("email", email)
    .eq("license_key", license_key)
    .maybeSingle();

  if (cErr) return err(500, "db", cErr.message);
  if (!centre) return err(404, "not_found", "Email ou clé de licence incorrects");
  if (centre.license_status !== "active") return err(403, "inactive", "Licence inactive");
  if (centre.license_expires_at && new Date(centre.license_expires_at) < new Date())
    return err(403, "expired", "Licence expirée");
  if (centre.password_set) return err(409, "already", "Mot de passe déjà défini, utilisez la connexion normale");

  let userId = centre.auth_user_id as string | null;

  if (!userId) {
    const { data: created, error: uErr } = await admin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { center_id: centre.id, app_role: "centre" },
    });
    if (uErr) {
      const { data: list } = await admin.auth.admin.listUsers({ page: 1, perPage: 1000 });
      const existing = list?.users?.find((u: any) => (u.email || "").toLowerCase() === email);
      if (existing) {
        userId = existing.id;
        const { error: pErr } = await admin.auth.admin.updateUserById(userId, { password });
        if (pErr) return err(500, "pwd_update", pErr.message);
      } else {
        return err(500, "create_user", uErr.message);
      }
    } else {
      userId = created.user!.id;
    }
  } else {
    const { error: pErr } = await admin.auth.admin.updateUserById(userId, { password });
    if (pErr) return err(500, "pwd_update", pErr.message);
  }

  const { error: linkErr } = await admin
    .from("centers")
    .update({ auth_user_id: userId, password_set: true })
    .eq("id", centre.id);
  if (linkErr) return err(500, "link", linkErr.message);

  return new Response(JSON.stringify({ ok: true, center_id: centre.id, center_nom: centre.nom }), { headers: CORS });
});
