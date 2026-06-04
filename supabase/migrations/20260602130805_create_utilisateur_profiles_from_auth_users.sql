create schema if not exists private;

revoke all on schema private from public, anon, authenticated;

create or replace function private.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.utilisateurs (id, nom, email)
  values (
    new.id,
    coalesce(
      nullif(trim(new.raw_user_meta_data ->> 'nom'), ''),
      split_part(coalesce(new.email, ''), '@', 1)
    ),
    coalesce(new.email, '')
  )
  on conflict (id) do update
  set
    email = excluded.email,
    nom = case
      when public.utilisateurs.nom = '' then excluded.nom
      else public.utilisateurs.nom
    end;

  return new;
end;
$$;

revoke all
  on function private.handle_new_auth_user()
  from public, anon, authenticated;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure private.handle_new_auth_user();

insert into public.utilisateurs (id, nom, email)
select
  id,
  coalesce(
    nullif(trim(raw_user_meta_data ->> 'nom'), ''),
    split_part(coalesce(email, ''), '@', 1)
  ),
  coalesce(email, '')
from auth.users
on conflict (id) do update
set
  email = excluded.email,
  nom = case
    when public.utilisateurs.nom = '' then excluded.nom
    else public.utilisateurs.nom
  end;
