-- Autorise tous les roles authentifies (utilisateur, moderateur, association,
-- admin) a ecrire leurs propres avis.
--
-- Corrige 20260602180000_harden_data_api_authorization.sql, qui restreignait
-- l'ecriture d'avis au seul role 'utilisateur' et bloquait donc, par erreur,
-- admin / moderateur / association.
--
-- L'insertion de lieux est deja ouverte a tout authentifie (lieu en attente de
-- validation) par 20260603091119_allow_user_pending_lieux.sql ; on ne la touche
-- donc pas ici pour ne pas casser la moderation.
-- Applique via: supabase db push

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
