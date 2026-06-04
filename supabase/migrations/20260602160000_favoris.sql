-- Favoris : relation N-N entre un Utilisateur et un Lieu.
-- Un utilisateur "met en favori" un lieu ; la table de liaison porte
-- l'horodatage de l'ajout. Chaque utilisateur ne gere que ses propres favoris.
-- Appliqué via: supabase db push

create table if not exists public.favoris (
  id_utilisateur uuid not null references auth.users (id) on delete cascade,
  id_lieu text not null references public.lieux (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (id_utilisateur, id_lieu)
);

-- RLS -----------------------------------------------------------------------
alter table public.favoris enable row level security;

-- Chacun lit, ajoute et retire uniquement ses propres favoris.
create policy "favoris_select_own" on public.favoris
  for select using (auth.uid() = id_utilisateur);
create policy "favoris_insert_own" on public.favoris
  for insert with check (auth.uid() = id_utilisateur);
create policy "favoris_delete_own" on public.favoris
  for delete using (auth.uid() = id_utilisateur);

-- Grants (Data API) ---------------------------------------------------------
grant select, insert, delete on table public.favoris to authenticated;

-- Realtime (pour les .stream cote Flutter).
alter publication supabase_realtime add table public.favoris;
