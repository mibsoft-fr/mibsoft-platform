import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

const MAILGUN_API_KEY = Deno.env.get("MAILGUN_API_KEY")!;
const MAILGUN_DOMAIN = Deno.env.get("MAILGUN_DOMAIN")!;

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, content-type",
      }
    });
  }

  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const { to, subject, html, from_name } = await req.json();

  const form = new FormData();
  form.append("from", `${from_name} <noreply@${MAILGUN_DOMAIN}>`);
  form.append("to", to);
  form.append("subject", subject);
  form.append("html", html);

  const resp = await fetch(
    `https://api.eu.mailgun.net/v3/${MAILGUN_DOMAIN}/messages`,
    {
      method: "POST",
      headers: { "Authorization": "Basic " + btoa(`api:${MAILGUN_API_KEY}`) },
      body: form,
    }
  );

  const result = await resp.json();
  return new Response(JSON.stringify(result), {
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*"
    }
  });
});