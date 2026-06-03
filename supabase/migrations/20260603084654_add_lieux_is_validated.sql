drop policy if exists "lieux_read_all" on public.lieux;
drop policy if exists lieux_select_validated_or_staff on public.lieux;
create policy lieux_select_validated_or_staff
on public.lieux for select
to anon, authenticated
using (
  is_validated
  or exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role in ('admin', 'moderateur')
  )
);

grant update (is_validated) on table public.lieux to authenticated;

drop policy if exists lieux_update_validation_staff on public.lieux;
create policy lieux_update_validation_staff
on public.lieux for update
to authenticated
using (
  exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role in ('admin', 'moderateur')
  )
)
with check (
  exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role in ('admin', 'moderateur')
  )
);
