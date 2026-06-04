-- Passe avis.note de int4 a float4 pour autoriser les notes decimales.
-- La contrainte check (note between 1 and 5) reste valide pour un real.
alter table public.avis
  alter column note type real;
