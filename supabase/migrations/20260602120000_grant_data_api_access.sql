grant select on table public.lieux to anon, authenticated;

grant select on table public.avis to anon, authenticated;
grant insert, update, delete on table public.avis to authenticated;
grant usage, select on sequence public.avis_id_avis_seq to authenticated;

grant select, insert, update on table public.utilisateurs to authenticated;
