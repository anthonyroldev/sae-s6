create table if not exists public.signup_email_domains (
  domain text primary key,
  created_at timestamptz not null default now(),
  constraint signup_email_domains_lowercase check (domain = lower(domain))
);

alter table public.signup_email_domains enable row level security;

revoke all on table public.signup_email_domains from anon, authenticated, public;
grant usage on schema public to supabase_auth_admin;
grant select on table public.signup_email_domains to supabase_auth_admin;

create policy "signup_email_domains_auth_hook_read"
  on public.signup_email_domains
  for select
  to supabase_auth_admin
  using (true);

insert into public.signup_email_domains (domain)
values
  ('insa-hdf.fr'),
  ('uphf.fr'),
  ('univ-lille.fr')
on conflict (domain) do nothing;

create or replace function public.hook_restrict_signup_by_email_domain(event jsonb)
returns jsonb
language plpgsql
stable
as $$
declare
  email_domain text;
  is_allowed boolean;
begin
  email_domain := lower(split_part(event->'user'->>'email', '@', 2));

  select exists (
    select 1
    from public.signup_email_domains
    where email_domain = domain
       or email_domain like '%.' || domain
  )
  into is_allowed;

  if is_allowed then
    return '{}'::jsonb;
  end if;

  return jsonb_build_object(
    'error',
    jsonb_build_object(
      'http_code', 403,
      'message', 'Utilisez une adresse email universitaire autorisee.'
    )
  );
end;
$$;

grant execute
  on function public.hook_restrict_signup_by_email_domain(jsonb)
  to supabase_auth_admin;

revoke execute
  on function public.hook_restrict_signup_by_email_domain(jsonb)
  from anon, authenticated, public;
