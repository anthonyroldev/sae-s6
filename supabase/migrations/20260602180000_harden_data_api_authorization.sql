alter table public.lieux alter column id set default gen_random_uuid()::text;

alter function public.hook_restrict_signup_by_email_domain(jsonb) set search_path = '';
alter function public.custom_access_token_hook(jsonb) set search_path = '';
alter function public.set_user_role(uuid, public.user_role) set search_path = '';

create index if not exists avis_id_lieu_idx on public.avis (id_lieu);
create index if not exists avis_id_utilisateur_idx on public.avis (id_utilisateur);
create index if not exists favoris_id_lieu_idx on public.favoris (id_lieu);
create index if not exists propositions_lieu_id_lieu_idx on public.propositions_lieu (id_lieu);
create index if not exists propositions_lieu_id_utilisateur_idx on public.propositions_lieu (id_utilisateur);
create index if not exists propositions_lieu_id_administrateur_idx on public.propositions_lieu (id_administrateur);

revoke all on table public.associations, public.avis, public.favoris, public.lieux,
  public.propositions_lieu, public.utilisateurs from anon;
revoke all on table public.associations, public.avis, public.favoris, public.lieux,
  public.propositions_lieu, public.utilisateurs from authenticated;

grant select on table public.associations, public.avis, public.lieux to anon, authenticated;
grant insert, update, delete on table public.associations to authenticated;
grant insert, update, delete on table public.avis to authenticated;
grant select, insert, delete on table public.favoris to authenticated;
grant insert on table public.lieux to authenticated;
grant select, insert, update, delete on table public.propositions_lieu to authenticated;
grant select on table public.utilisateurs to authenticated;
grant insert (id, nom, email, position_gps) on table public.utilisateurs to authenticated;
grant update (nom, email, position_gps) on table public.utilisateurs to authenticated;

drop policy if exists avis_insert_own on public.avis;
drop policy if exists avis_update_own on public.avis;
drop policy if exists avis_delete_own on public.avis;
drop policy if exists avis_utilisateur_insert_own on public.avis;
drop policy if exists avis_utilisateur_update_own on public.avis;
drop policy if exists avis_utilisateur_delete_own on public.avis;
drop policy if exists lieux_utilisateur_insert on public.lieux;

create policy avis_utilisateur_insert_own
on public.avis for insert
to authenticated
with check (
  (select auth.uid()) = id_utilisateur
  and exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role = 'utilisateur'
  )
);

create policy avis_utilisateur_update_own
on public.avis for update
to authenticated
using (
  (select auth.uid()) = id_utilisateur
  and exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role = 'utilisateur'
  )
)
with check (
  (select auth.uid()) = id_utilisateur
  and exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role = 'utilisateur'
  )
);

create policy avis_utilisateur_delete_own
on public.avis for delete
to authenticated
using (
  (select auth.uid()) = id_utilisateur
  and exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role = 'utilisateur'
  )
);

create policy lieux_utilisateur_insert
on public.lieux for insert
to authenticated
with check (
  exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role = 'utilisateur'
  )
);

drop policy if exists utilisateurs_self_insert on public.utilisateurs;
drop policy if exists utilisateurs_self_select on public.utilisateurs;
drop policy if exists utilisateurs_self_update on public.utilisateurs;

create policy utilisateurs_self_insert
on public.utilisateurs for insert
to authenticated
with check ((select auth.uid()) = id);

create policy utilisateurs_self_select
on public.utilisateurs for select
to authenticated
using ((select auth.uid()) = id);

create policy utilisateurs_self_update
on public.utilisateurs for update
to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

drop policy if exists favoris_insert_own on public.favoris;
drop policy if exists favoris_select_own on public.favoris;
drop policy if exists favoris_delete_own on public.favoris;

create policy favoris_insert_own
on public.favoris for insert
to authenticated
with check ((select auth.uid()) = id_utilisateur);

create policy favoris_select_own
on public.favoris for select
to authenticated
using ((select auth.uid()) = id_utilisateur);

create policy favoris_delete_own
on public.favoris for delete
to authenticated
using ((select auth.uid()) = id_utilisateur);

drop policy if exists propositions_insert_own on public.propositions_lieu;
drop policy if exists propositions_select_own_or_staff on public.propositions_lieu;
drop policy if exists propositions_update_staff on public.propositions_lieu;
drop policy if exists propositions_delete_own_or_admin on public.propositions_lieu;

create policy propositions_insert_own
on public.propositions_lieu for insert
to authenticated
with check (
  (select auth.uid()) = id_utilisateur
  and statut = 'en_attente'
  and id_administrateur is null
);

create policy propositions_select_own_or_staff
on public.propositions_lieu for select
to authenticated
using (
  (select auth.uid()) = id_utilisateur
  or exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role in ('admin', 'moderateur')
  )
);

create policy propositions_update_staff
on public.propositions_lieu for update
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

create policy propositions_delete_own_or_admin
on public.propositions_lieu for delete
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

drop policy if exists associations_write_staff on public.associations;
drop policy if exists associations_insert_staff on public.associations;
drop policy if exists associations_update_staff on public.associations;
drop policy if exists associations_delete_staff on public.associations;

create policy associations_insert_staff
on public.associations for insert
to authenticated
with check (
  exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role in ('admin', 'association')
  )
);

create policy associations_update_staff
on public.associations for update
to authenticated
using (
  exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role in ('admin', 'association')
  )
)
with check (
  exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role in ('admin', 'association')
  )
);

create policy associations_delete_staff
on public.associations for delete
to authenticated
using (
  exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role in ('admin', 'association')
  )
);

create or replace function public.set_user_role(
  target_user uuid,
  new_role public.user_role
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not exists (
    select 1
    from public.utilisateurs
    where id = (select auth.uid())
      and role = 'admin'
  ) then
    raise exception 'Seul un administrateur peut modifier les roles'
      using errcode = '42501';
  end if;

  update public.utilisateurs
     set role = new_role
   where id = target_user;
end;
$$;
