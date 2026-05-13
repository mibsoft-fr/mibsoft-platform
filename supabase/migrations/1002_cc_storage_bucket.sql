-- =====================================================================
-- Storage bucket pour les médias des cc_questions (image / vidéo)
-- Upload depuis l'admin UI, lecture publique pour affichage en jeu.
-- =====================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'question-media',
  'question-media',
  true,
  52428800, -- 50 MB
  array[
    'image/png','image/jpeg','image/webp','image/gif','image/svg+xml',
    'video/mp4','video/webm','video/quicktime'
  ]
)
on conflict (id) do nothing;

-- Lecture publique des médias
create policy "Public read question-media"
  on storage.objects for select
  using (bucket_id = 'question-media');

-- Upload limité (sera resserré quand l'auth admin sera en place — Phase 2)
create policy "Public insert question-media"
  on storage.objects for insert
  with check (bucket_id = 'question-media');

create policy "Public update question-media"
  on storage.objects for update
  using (bucket_id = 'question-media');

create policy "Public delete question-media"
  on storage.objects for delete
  using (bucket_id = 'question-media');
