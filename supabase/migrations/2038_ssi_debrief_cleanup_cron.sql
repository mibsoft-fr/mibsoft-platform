-- 2038 — Filet de sécurité RGPD : purge planifiée des vidéos de débriefing.
--
-- Nominal : la vidéo de débriefing (bucket privé `ssi-debriefs`) est purgée
-- côté client dès que le formateur se déconnecte de la session
-- (formateurDisconnect() → purgeAllSessionVideos()). Elle n'est donc conservée
-- que le temps du débriefing, au maximum la durée de la formation. Ni le centre
-- ni le formateur ne peuvent extraire/copier la vidéo (aucun bouton de
-- téléchargement, bucket privé sans accès à la source de stockage).
--
-- Filet de sécurité : si le formateur ne se déconnecte jamais (onglet fermé
-- brutalement, crash, perte réseau), la purge client ne se déclenche pas. Ce
-- job cron appelle chaque heure l'Edge Function `ssi-debrief-cleanup`, qui
-- supprime PHYSIQUEMENT (storage API, service role) tout objet plus vieux que
-- DEBRIEF_MAX_AGE_HOURS (défaut 24h). Aucune vidéo ne survit au-delà.
--
-- NOTE : le token Bearer (clé anon/JWT du projet) n'est PAS versionné ici pour
-- ne pas exposer de secret. Le job est créé via `cron.schedule(...)` exécuté
-- hors dépôt (MCP/SQL) avec l'en-tête Authorization renseigné. Ce fichier
-- documente l'infrastructure et rend les extensions requises idempotentes.

create extension if not exists pg_net with schema extensions;
create extension if not exists pg_cron;

-- Le job effectif (avec l'en-tête Authorization) est planifié hors dépôt :
--
--   select cron.schedule(
--     'ssi-debrief-cleanup-hourly',
--     '17 * * * *',
--     $$
--     select net.http_post(
--       url := 'https://<project-ref>.supabase.co/functions/v1/ssi-debrief-cleanup',
--       headers := jsonb_build_object(
--         'Authorization', 'Bearer <anon-or-service-role-jwt>',
--         'Content-Type', 'application/json'
--       ),
--       body := '{}'::jsonb,
--       timeout_milliseconds := 30000
--     );
--     $$
--   );
