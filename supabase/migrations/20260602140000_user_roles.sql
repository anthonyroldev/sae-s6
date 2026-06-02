-- Rôles applicatifs (admin / modérateur / association / utilisateur).
-- Le rôle vit sur utilisateurs.role et est injecté dans le JWT via un
-- custom access token hook, pour que les RLS et le client le lisent sans
-- requête récursive.
-- Appliqué via: supabase db push

-- Enum des rôles. 'utilisateur' est le rôle par défaut de tout compte.
create type public.user_role as enum (
  'utilisateur',
  'moderateur',
  'association',
  'admin'
);

alter table public.utilisateurs
  add column if not exists role public.user_role not null default 'utilisateur';

-- Anti-escalade : un utilisateur peut éditer son profil mais PAS son rôle.
-- On remplace les GRANT pleine table par des grants au niveau colonne, ce qui
-- exclut la colonne `role` des écritures faites avec le rôle `authenticated`.
revoke insert, update on table public.utilisateurs from authenticated;
grant insert (id, nom, email, position_gps)
  on table public.utilisateurs to authenticated;
grant update (nom, email, position_gps)
  on table public.utilisateurs to authenticated;

-- Custom access token hook : ajoute le rôle courant au JWT (claim user_role).
-- Défaut 'utilisateur' tant que la ligne de profil n'existe pas encore.
create or replace function public.custom_access_token_hook(event jsonb)
returns jsonb
language plpgsql
stable
as $$
declare
  claims jsonb;
  resolved_role public.user_role;
begin
  select role
    into resolved_role
    from public.utilisateurs
   where id = (event ->> 'user_id')::uuid;

  claims := event -> 'claims';
  claims := jsonb_set(
    claims,
    '{user_role}',
    to_jsonb(coalesce(resolved_role, 'utilisateur')::text)
  );

  return jsonb_set(event, '{claims}', claims);
end;
$$;

-- Le hook s'exécute sous le rôle supabase_auth_admin.
grant usage on schema public to supabase_auth_admin;
grant execute
  on function public.custom_access_token_hook(jsonb)
  to supabase_auth_admin;
revoke execute
  on function public.custom_access_token_hook(jsonb)
  from anon, authenticated, public;

-- Le hook doit pouvoir lire le rôle malgré la RLS.
grant select on table public.utilisateurs to supabase_auth_admin;
create policy "utilisateurs_auth_hook_read"
  on public.utilisateurs
  for select
  to supabase_auth_admin
  using (true);

-- Promotion / rétrogradation : réservée aux admins, via cette fonction.
-- SECURITY DEFINER => contourne les grants colonne, mais le garde-fou est la
-- vérification du claim user_role de l'appelant.
create or replace function public.set_user_role(
  target_user uuid,
  new_role public.user_role
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if coalesce(auth.jwt() ->> 'user_role', 'utilisateur') <> 'admin' then
    raise exception 'Seul un administrateur peut modifier les roles'
      using errcode = '42501';
  end if;

  update public.utilisateurs
     set role = new_role
   where id = target_user;
end;
$$;

revoke execute
  on function public.set_user_role(uuid, public.user_role)
  from anon, public;
grant execute
  on function public.set_user_role(uuid, public.user_role)
  to authenticated;
