alter table public.lieux
  drop column if exists horaire;

alter table public.lieux
  add column if not exists heure_ouverture time,
  add column if not exists heure_fermeture time;

