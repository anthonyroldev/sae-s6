create or replace view public.utilisateurs_public as
select id, nom
from public.utilisateurs;

revoke all on table public.utilisateurs_public from public;
grant select on table public.utilisateurs_public to authenticated;
