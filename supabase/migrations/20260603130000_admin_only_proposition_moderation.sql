drop policy if exists propositions_select_own_or_staff on public.propositions_lieu;
drop policy if exists propositions_update_staff on public.propositions_lieu;

create policy propositions_select_own_or_admin
on public.propositions_lieu for select
to authenticated
using (
  (select auth.uid()) = id_utilisateur
  or exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role = 'admin'
  )
);

create policy propositions_update_admin
on public.propositions_lieu for update
to authenticated
using (
  exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role = 'admin'
  )
)
with check (
  exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role = 'admin'
  )
);

drop policy if exists lieux_select_validated_or_staff on public.lieux;
drop policy if exists lieux_update_validation_staff on public.lieux;

create policy lieux_select_validated_or_admin
on public.lieux for select
to anon, authenticated
using (
  is_validated
  or exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role = 'admin'
  )
);

create policy lieux_update_validation_admin
on public.lieux for update
to authenticated
using (
  exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role = 'admin'
  )
)
with check (
  exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role = 'admin'
  )
);
