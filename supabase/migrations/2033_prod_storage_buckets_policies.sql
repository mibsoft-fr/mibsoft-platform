-- 2033 — Buckets Storage + policies (réplique DEV → PROD).
-- Les buckets et les policies du schéma "storage" ne font PAS partie du clone de
-- schéma "public" : il faut les recréer explicitement sur la base de production.
-- Migration idempotente (ON CONFLICT / DROP POLICY IF EXISTS) : sans effet en DEV
-- où tout existe déjà.

-- ── Buckets ────────────────────────────────────────────────────────────────
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
  ('documents',      'documents',      true,  52428800, null),
  ('pdf-references', 'pdf-references', true,  null,     null),
  ('photos',         'photos',         true,  10485760, null),
  ('question-media', 'question-media', true,  52428800, array['image/png','image/jpeg','image/webp','image/gif','image/svg+xml','video/mp4','video/webm','video/quicktime']),
  ('sounds',         'sounds',         true,  10485760, array['audio/mpeg','audio/ogg','audio/wav','audio/webm']),
  ('ssi-plan-media', 'ssi-plan-media', true,  null,     null),
  ('ssi-plans',      'ssi-plans',      false, 10485760, null),
  ('videos',         'videos',         true,  52428800, null)
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- ── Policies publiques simples ─────────────────────────────────────────────
drop policy if exists "allow_all_pdf_references" on storage.objects;
create policy "allow_all_pdf_references" on storage.objects
  for all to public using (bucket_id = 'pdf-references') with check (bucket_id = 'pdf-references');

drop policy if exists "lecture_publique_documents" on storage.objects;
create policy "lecture_publique_documents" on storage.objects
  for select to public using (bucket_id = 'documents');
drop policy if exists "lecture_publique_photos" on storage.objects;
create policy "lecture_publique_photos" on storage.objects
  for select to public using (bucket_id = 'photos');
drop policy if exists "lecture_publique_videos" on storage.objects;
create policy "lecture_publique_videos" on storage.objects
  for select to public using (bucket_id = 'videos');

drop policy if exists "upload_anon_documents" on storage.objects;
create policy "upload_anon_documents" on storage.objects
  for insert to anon with check (bucket_id = 'documents');
drop policy if exists "upload_anon_photos" on storage.objects;
create policy "upload_anon_photos" on storage.objects
  for insert to anon with check (bucket_id = 'photos');
drop policy if exists "upload_anon_videos" on storage.objects;
create policy "upload_anon_videos" on storage.objects
  for insert to anon with check (bucket_id = 'videos');

-- ── question-media (lecture/écriture publiques) ────────────────────────────
drop policy if exists "cc_question-media read" on storage.objects;
create policy "cc_question-media read" on storage.objects
  for select to public using (bucket_id = 'question-media');
drop policy if exists "cc_question-media insert" on storage.objects;
create policy "cc_question-media insert" on storage.objects
  for insert to public with check (bucket_id = 'question-media');
drop policy if exists "cc_question-media update" on storage.objects;
create policy "cc_question-media update" on storage.objects
  for update to public using (bucket_id = 'question-media');
drop policy if exists "cc_question-media delete" on storage.objects;
create policy "cc_question-media delete" on storage.objects
  for delete to public using (bucket_id = 'question-media');

-- ── sounds (lecture/écriture publiques) ────────────────────────────────────
drop policy if exists "cc_sounds read" on storage.objects;
create policy "cc_sounds read" on storage.objects
  for select to public using (bucket_id = 'sounds');
drop policy if exists "cc_sounds insert" on storage.objects;
create policy "cc_sounds insert" on storage.objects
  for insert to public with check (bucket_id = 'sounds');
drop policy if exists "cc_sounds update" on storage.objects;
create policy "cc_sounds update" on storage.objects
  for update to public using (bucket_id = 'sounds');
drop policy if exists "cc_sounds delete" on storage.objects;
create policy "cc_sounds delete" on storage.objects
  for delete to public using (bucket_id = 'sounds');

-- ── ssi-plan-media (par centre + dossier partagé super-admin) ──────────────
drop policy if exists "ssiplanmedia_insert" on storage.objects;
create policy "ssiplanmedia_insert" on storage.objects
  for insert to authenticated with check (
    (bucket_id = 'ssi-plan-media') AND (
      (EXISTS (SELECT 1 FROM formateurs f WHERE f.auth_user_id = auth.uid() AND (f.center_id)::text = split_part(objects.name, '/', 1)))
      OR (EXISTS (SELECT 1 FROM centers c WHERE c.auth_user_id = auth.uid() AND (c.id)::text = split_part(objects.name, '/', 1)))
    )
  );
drop policy if exists "ssiplanmedia_update" on storage.objects;
create policy "ssiplanmedia_update" on storage.objects
  for update to authenticated
  using (
    (bucket_id = 'ssi-plan-media') AND (
      (EXISTS (SELECT 1 FROM formateurs f WHERE f.auth_user_id = auth.uid() AND (f.center_id)::text = split_part(objects.name, '/', 1)))
      OR (EXISTS (SELECT 1 FROM centers c WHERE c.auth_user_id = auth.uid() AND (c.id)::text = split_part(objects.name, '/', 1)))
    )
  )
  with check (
    (bucket_id = 'ssi-plan-media') AND (
      (EXISTS (SELECT 1 FROM formateurs f WHERE f.auth_user_id = auth.uid() AND (f.center_id)::text = split_part(objects.name, '/', 1)))
      OR (EXISTS (SELECT 1 FROM centers c WHERE c.auth_user_id = auth.uid() AND (c.id)::text = split_part(objects.name, '/', 1)))
    )
  );
drop policy if exists "ssiplanmedia_delete" on storage.objects;
create policy "ssiplanmedia_delete" on storage.objects
  for delete to authenticated
  using (
    (bucket_id = 'ssi-plan-media') AND (
      (EXISTS (SELECT 1 FROM formateurs f WHERE f.auth_user_id = auth.uid() AND (f.center_id)::text = split_part(objects.name, '/', 1)))
      OR (EXISTS (SELECT 1 FROM centers c WHERE c.auth_user_id = auth.uid() AND (c.id)::text = split_part(objects.name, '/', 1)))
    )
  );

drop policy if exists "ssiplanmedia_shared_insert" on storage.objects;
create policy "ssiplanmedia_shared_insert" on storage.objects
  for insert to authenticated with check (
    (bucket_id = 'ssi-plan-media') AND (split_part(name, '/', 1) = 'shared') AND (is_super_admin(owner) OR storage_is_super_admin())
  );
drop policy if exists "ssiplanmedia_shared_update" on storage.objects;
create policy "ssiplanmedia_shared_update" on storage.objects
  for update to authenticated
  using ((bucket_id = 'ssi-plan-media') AND (split_part(name, '/', 1) = 'shared') AND (is_super_admin(owner) OR storage_is_super_admin()))
  with check ((bucket_id = 'ssi-plan-media') AND (split_part(name, '/', 1) = 'shared') AND (is_super_admin(owner) OR storage_is_super_admin()));
drop policy if exists "ssiplanmedia_shared_delete" on storage.objects;
create policy "ssiplanmedia_shared_delete" on storage.objects
  for delete to authenticated
  using ((bucket_id = 'ssi-plan-media') AND (split_part(name, '/', 1) = 'shared') AND (is_super_admin(owner) OR storage_is_super_admin()));

-- ── ssi-plans (privé : lecture par centre + dossier partagé) ───────────────
drop policy if exists "ssiplans_read" on storage.objects;
create policy "ssiplans_read" on storage.objects
  for select to authenticated using (
    (bucket_id = 'ssi-plans') AND (
      (split_part(name, '/', 1) = 'shared')
      OR (EXISTS (SELECT 1 FROM ssi_user_center_ids() c(c) WHERE (c.c)::text = split_part(objects.name, '/', 1)))
    )
  );
drop policy if exists "ssiplans_insert" on storage.objects;
create policy "ssiplans_insert" on storage.objects
  for insert to authenticated with check (
    (bucket_id = 'ssi-plans') AND (
      (EXISTS (SELECT 1 FROM formateurs f WHERE f.auth_user_id = auth.uid() AND (f.center_id)::text = split_part(objects.name, '/', 1)))
      OR (EXISTS (SELECT 1 FROM centers c WHERE c.auth_user_id = auth.uid() AND (c.id)::text = split_part(objects.name, '/', 1)))
    )
  );
drop policy if exists "ssiplans_update" on storage.objects;
create policy "ssiplans_update" on storage.objects
  for update to authenticated
  using (
    (bucket_id = 'ssi-plans') AND (
      (EXISTS (SELECT 1 FROM formateurs f WHERE f.auth_user_id = auth.uid() AND (f.center_id)::text = split_part(objects.name, '/', 1)))
      OR (EXISTS (SELECT 1 FROM centers c WHERE c.auth_user_id = auth.uid() AND (c.id)::text = split_part(objects.name, '/', 1)))
    )
  )
  with check (
    (bucket_id = 'ssi-plans') AND (
      (EXISTS (SELECT 1 FROM formateurs f WHERE f.auth_user_id = auth.uid() AND (f.center_id)::text = split_part(objects.name, '/', 1)))
      OR (EXISTS (SELECT 1 FROM centers c WHERE c.auth_user_id = auth.uid() AND (c.id)::text = split_part(objects.name, '/', 1)))
    )
  );
drop policy if exists "ssiplans_center_delete" on storage.objects;
create policy "ssiplans_center_delete" on storage.objects
  for delete to authenticated
  using (
    (bucket_id = 'ssi-plans') AND (
      (EXISTS (SELECT 1 FROM formateurs f WHERE f.auth_user_id = auth.uid() AND (f.center_id)::text = split_part(objects.name, '/', 1)))
      OR (EXISTS (SELECT 1 FROM centers c WHERE c.auth_user_id = auth.uid() AND (c.id)::text = split_part(objects.name, '/', 1)))
    )
  );

drop policy if exists "ssiplans_shared_insert" on storage.objects;
create policy "ssiplans_shared_insert" on storage.objects
  for insert to authenticated with check (
    (bucket_id = 'ssi-plans') AND (split_part(name, '/', 1) = 'shared') AND jwt_is_super_admin()
  );
drop policy if exists "ssiplans_shared_update" on storage.objects;
create policy "ssiplans_shared_update" on storage.objects
  for update to authenticated
  using ((bucket_id = 'ssi-plans') AND (split_part(name, '/', 1) = 'shared') AND jwt_is_super_admin())
  with check ((bucket_id = 'ssi-plans') AND (split_part(name, '/', 1) = 'shared') AND jwt_is_super_admin());
drop policy if exists "ssiplans_shared_delete" on storage.objects;
create policy "ssiplans_shared_delete" on storage.objects
  for delete to authenticated
  using ((bucket_id = 'ssi-plans') AND (split_part(name, '/', 1) = 'shared') AND jwt_is_super_admin());
