insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'lieux',
  'lieux',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists lieux_images_read_public on storage.objects;
drop policy if exists lieux_images_insert_authenticated on storage.objects;

create policy lieux_images_read_public
on storage.objects for select
to public
using (bucket_id = 'lieux');

create policy lieux_images_insert_authenticated
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'lieux'
  and (storage.foldername(name))[1] = 'places'
);
