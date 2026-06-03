grant insert on table public.lieux to authenticated;

drop policy if exists lieux_utilisateur_insert on public.lieux;
drop policy if exists lieux_authenticated_insert_pending on public.lieux;
create policy lieux_authenticated_insert_pending
on public.lieux for insert
to authenticated
with check (
  (select auth.uid()) is not null
  and is_validated = false
);
