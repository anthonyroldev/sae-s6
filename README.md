# Le Repère

Flutter app for discovering student places in Valenciennes.

## Prerequisites

- Flutter SDK stable
- Android Studio or Xcode for mobile targets
- Supabase project

```bash
flutter --version
flutter doctor
flutter pub get
```

## Supabase

Run migrations:

```bash
supabase db push
```

Load fake places locally:

```bash
supabase db reset
```

Load fake places on the hosted project:

```bash
supabase db push --include-seed
```

The signup domain restriction uses a `before-user-created` SQL Auth Hook.

For the hosted project:

1. Open Supabase Dashboard.
2. Go to `Authentication` → `Hooks`.
3. Enable `Before User Created`.
4. Select `Postgres`.
5. Select `public.hook_restrict_signup_by_email_domain`.

Allowed signup domains:

- `insa-hdf.fr`
- `uphf.fr`
- `univ-lille.fr`
- their subdomains

## User roles

Each account carries a role (`utilisateur`, `moderateur`, `association`, `admin`)
stored on `utilisateurs.role`. A `custom-access-token` SQL Auth Hook injects it
into the JWT as the `user_role` claim, read client-side by `RoleSource`.

For the hosted project, enable the hook:

1. Open Supabase Dashboard.
2. Go to `Authentication` → `Hooks`.
3. Enable `Customize Access Token (JWT) Claims`.
4. Select `Postgres`.
5. Select `public.custom_access_token_hook`.

New accounts default to `utilisateur`. From the app, an admin promotes a user
through the `set_user_role` RPC (it rejects non-admin callers).

To bootstrap the first admin, run a direct update from the Dashboard SQL editor
(postgres bypasses the column grants; the RPC's admin check does not apply to a
plain `update`):

```sql
update public.utilisateurs set role = 'admin' where email = '<your-email>';
```

The promoted user must refresh their session (sign out/in) for the new
`user_role` claim to appear in their JWT.

## Launch

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<publishable-or-anon-key>
```

Chrome fallback:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<publishable-or-anon-key>
```

## Quality Checks

```bash
dart format lib/ test/
flutter analyze
flutter test
```

## Debug Builds

```bash
flutter build apk --debug
flutter build ios --debug --no-codesign
```
