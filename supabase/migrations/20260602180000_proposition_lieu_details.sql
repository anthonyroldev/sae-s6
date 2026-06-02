-- Étend propositions_lieu pour porter les données du lieu candidat, afin que la
-- modération affiche et valide une proposition sans lieu pré-existant.
-- Complète 20260602170000_associations_propositions.sql (flux pré-modération :
-- une proposition `en_attente` ne devient un lieu publié qu'après validation).
-- Appliqué via: supabase db push

alter table public.propositions_lieu
  add column if not exists nom text not null default '',
  add column if not exists description text not null default '',
  add column if not exists latitude double precision not null default 0,
  add column if not exists longitude double precision not null default 0,
  add column if not exists heure_ouverture time,
  add column if not exists heure_fermeture time,
  add column if not exists image_url text not null default '',
  add column if not exists categorie text not null default 'services';

-- Validation : réservée au staff (admin/modérateur). SECURITY DEFINER pour
-- pouvoir écrire dans `lieux` (interdit aux clients) ; garde-fou = claim JWT.
create or replace function public.valider_proposition(p_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  caller_role text := coalesce(auth.jwt() ->> 'user_role', 'utilisateur');
  new_lieu_id text := 'lieu-' || p_id;
begin
  if caller_role not in ('admin', 'moderateur') then
    raise exception 'Action reservee aux moderateurs' using errcode = '42501';
  end if;

  insert into public.lieux (
    id, nom, description, latitude, longitude,
    heure_ouverture, heure_fermeture, image_url, categorie
  )
  select
    new_lieu_id, p.nom, p.description, p.latitude, p.longitude,
    p.heure_ouverture, p.heure_fermeture, p.image_url, p.categorie
  from public.propositions_lieu p
  where p.id_proposition = p_id
    and p.statut = 'en_attente';

  update public.propositions_lieu
     set statut = 'validee',
         id_lieu = new_lieu_id,
         id_administrateur = auth.uid()
   where id_proposition = p_id
     and statut = 'en_attente';
end;
$$;

-- Refus : réservé au staff.
create or replace function public.refuser_proposition(p_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  caller_role text := coalesce(auth.jwt() ->> 'user_role', 'utilisateur');
begin
  if caller_role not in ('admin', 'moderateur') then
    raise exception 'Action reservee aux moderateurs' using errcode = '42501';
  end if;

  update public.propositions_lieu
     set statut = 'refusee',
         id_administrateur = auth.uid()
   where id_proposition = p_id
     and statut = 'en_attente';
end;
$$;

revoke execute on function public.valider_proposition(bigint) from anon, public;
revoke execute on function public.refuser_proposition(bigint) from anon, public;
grant execute on function public.valider_proposition(bigint) to authenticated;
grant execute on function public.refuser_proposition(bigint) to authenticated;
