-- Bucket pour les fichiers audio (applaudissements, gong, buzzer customs).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('sounds','sounds',true,10485760,
  array['audio/mpeg','audio/ogg','audio/wav','audio/webm'])
on conflict (id) do nothing;

create policy "Public read sounds"   on storage.objects for select using (bucket_id='sounds');
create policy "Public insert sounds" on storage.objects for insert with check (bucket_id='sounds');
create policy "Public update sounds" on storage.objects for update using (bucket_id='sounds');
create policy "Public delete sounds" on storage.objects for delete using (bucket_id='sounds');
