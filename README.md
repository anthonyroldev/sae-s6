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
