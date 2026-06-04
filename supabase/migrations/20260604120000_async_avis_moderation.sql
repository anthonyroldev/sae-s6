alter table public.avis
add column if not exists is_validated boolean not null default false,
add column if not exists moderation_status text not null default 'pending';

update public.avis
set is_validated = true,
    moderation_status = 'accepted'
where moderation_status = 'pending';

alter table public.avis
drop constraint if exists avis_moderation_status_check;

alter table public.avis
add constraint avis_moderation_status_check
check (moderation_status in ('pending', 'accepted', 'denied'));

create index if not exists avis_lieu_validated_created_at_idx
on public.avis (id_lieu, is_validated, created_at desc);

drop policy if exists avis_read_all on public.avis;
drop policy if exists avis_select_public_validated on public.avis;
drop policy if exists avis_select_own on public.avis;
drop policy if exists avis_insert_own on public.avis;
drop policy if exists avis_update_own on public.avis;
drop policy if exists avis_delete_own on public.avis;

create policy avis_select_public_validated
on public.avis for select
to anon, authenticated
using (is_validated = true and moderation_status = 'accepted');

create policy avis_select_own
on public.avis for select
to authenticated
using ((select auth.uid()) = id_utilisateur);

create policy avis_insert_own
on public.avis for insert
to authenticated
with check (
  (select auth.uid()) = id_utilisateur
  and is_validated = false
  and moderation_status = 'pending'
);

create policy avis_update_own
on public.avis for update
to authenticated
using (
  (select auth.uid()) = id_utilisateur
  and moderation_status = 'pending'
)
with check (
  (select auth.uid()) = id_utilisateur
  and is_validated = false
  and moderation_status = 'pending'
);

create policy avis_delete_own
on public.avis for delete
to authenticated
using ((select auth.uid()) = id_utilisateur);
