-- Autorise tous les roles authentifies (utilisateur, moderateur, association,
-- admin) a creer un lieu et a gerer leurs propres avis.
--
-- Corrige 20260602180000_harden_data_api_authorization.sql, qui restreignait
-- l'insertion de lieux et l'ecriture d'avis au seul role 'utilisateur' et
-- bloquait donc, par erreur, admin / moderateur / association.
-- Appliqué via: supabase db push

-- Avis : ecriture reservee a l'auteur, quel que soit son role.
drop policy if exists avis_utilisateur_insert_own on public.avis;
drop policy if exists avis_utilisateur_update_own on public.avis;
drop policy if exists avis_utilisateur_delete_own on public.avis;
drop policy if exists avis_insert_own on public.avis;
drop policy if exists avis_update_own on public.avis;
drop policy if exists avis_delete_own on public.avis;

create policy avis_insert_own
on public.avis for insert
to authenticated
with check ((select auth.uid()) = id_utilisateur);

create policy avis_update_own
on public.avis for update
to authenticated
using ((select auth.uid()) = id_utilisateur)
with check ((select auth.uid()) = id_utilisateur);

create policy avis_delete_own
on public.avis for delete
to authenticated
using ((select auth.uid()) = id_utilisateur);

-- Lieux : tout utilisateur authentifie peut creer un lieu.
drop policy if exists lieux_utilisateur_insert on public.lieux;
drop policy if exists lieux_insert_authenticated on public.lieux;

create policy lieux_insert_authenticated
on public.lieux for insert
to authenticated
with check (true);
