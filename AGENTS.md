# AGENTS.md - Le Repere

Flutter mobile app for discovering campus places at INSA Hauts-de-France.
Team of 5 - Scrum - Dart/Flutter - Supabase

---

## Environment

- **Flutter SDK:** stable channel - run `flutter --version` to confirm
- **Dart:** included with Flutter, no separate install
- **Target platforms:** Android + iOS
- **Package manager:** `pub` via `flutter pub`
- **Backend:** Supabase Auth + Postgres + Realtime

Do not use `npm`, `pip`, Firebase, or non-Dart tooling unless explicitly asked.

---

## Commands

### Setup
```bash
flutter pub get
```

### Run
```bash
flutter run --dart-define=SUPABASE_URL=<project-url> --dart-define=SUPABASE_ANON_KEY=<publishable-or-anon-key>
flutter run -d chrome --dart-define=SUPABASE_URL=<project-url> --dart-define=SUPABASE_ANON_KEY=<publishable-or-anon-key>
```

### Build
```bash
flutter build apk --debug
flutter build ios --debug --no-codesign
```

### Analyze
```bash
flutter analyze
```

Zero warnings policy.

### Test
```bash
flutter test
flutter test --coverage
```

Run `flutter analyze && flutter test` before every commit.

---

## Dependencies

| Package | Purpose |
|---|---|
| `supabase_flutter` | Auth, Postgres API, Realtime |
| `flutter_map` | Campus map |
| `latlong2` | Map coordinates |
| `geolocator` | Current device position |
| `flutter_svg` | SVG assets |
| `logger` | Production logs |

Keep dependencies minimal. Pin versions in `pubspec.yaml`. Commit `pubspec.lock`.

---

## Project Structure

```text
lib/
|-- components/              # shared navigation widgets
|-- core/
|   |-- constants/           # colors and spacing tokens
|   `-- utils/               # validation, conversion, shared logger
|-- data/
|   |-- models/              # Supabase row models and serializers
|   `-- sources/             # Supabase Auth/Postgres/Realtime access
|-- pages/
|   |-- auth/                # email/password authentication flow
|   |-- feed/                # feed widgets
|   `-- profil/              # profile widgets
`-- main.dart                # Supabase initialization + app root
```

Current code uses direct data sources. Do not invent repositories, domain layers,
or Riverpod providers unless the architecture is explicitly migrated first.

---

## Implemented Features

- Splash screen.
- Email and password login and signup.
- Signup restricted to institutional email domains.
- Auth session gate and logout.
- User roles (utilisateur, moderateur, association, admin) carried in the JWT.
- Realtime campus place feed.
- Feed search and category filters.
- Favorite places (add/remove, per user).
- Add-place form with validation and optional image upload.
- Device geolocation for place coordinates.
- Campus map with place markers.
- Profile screen.

---

## State Management

Current app uses Flutter state primitives:

- `setState` for local widget state.
- `ValueNotifier` and `ValueListenableBuilder` for focused form/filter state.
- `StreamBuilder` for Supabase Auth and Realtime streams.

Do not add Riverpod, Bloc, GetX, or Provider unless requested.

Keep business validation outside widgets when reusable.

---

## Supabase

Initialize Supabase only in `lib/main.dart`.

Required build-time values:

```text
SUPABASE_URL
SUPABASE_ANON_KEY
```

Use `--dart-define`. Never hardcode keys. Never expose `service_role` or secret
keys in the Flutter client. A publishable key is preferred; legacy anon keys are
accepted for compatibility.

### Auth

- Provider: Supabase Auth (`GoTrue`).
- Flow: `signInWithPassword` for login, `signUp` (email + password) for signup.
- Password: minimum 8 characters, enforced by the UI before the call.
- Email confirmation must be disabled in Supabase (Auth > Providers > Email);
  signup expects a session back immediately.
- Signup writes or updates the profile row in `utilisateurs`.
- User primary key: Supabase Auth user id (`auth.uid()`).
- Role: delivered as the `user_role` JWT claim by the custom access token hook,
  read client-side by `RoleSource`; changed only through the `set_user_role` RPC.

### Active Tables

```text
lieux
  id (text, default gen_random_uuid()), nom, description, latitude, longitude,
  heure_ouverture, heure_fermeture, image_url, categorie

avis
  id_avis, note (real, check 1..5), commentaire, created_at, id_lieu, id_utilisateur

utilisateurs
  id, nom, email, position_gps, role (user_role enum, default 'utilisateur')

favoris
  id_utilisateur, id_lieu   -- composite key, one row per favorited place

associations
  id_association, nom, description, contact

propositions_lieu
  id_proposition, statut, id_lieu, id_utilisateur, id_administrateur, created_at
```

### Sources

```text
AuthSupabaseSource         # email/password auth, session stream, logout
LieuSupabaseSource         # realtime watch + insert + image upload/remove
AvisSupabaseSource         # realtime watch by place + validated upsert
FavorisSupabaseSource      # watch/add/remove the current user's favorites
UtilisateurSupabaseSource  # watch/get/upsert profile
RoleSource                 # reads the user_role JWT claim; set_user_role RPC
```

### Security

- Enable RLS on every exposed table.
- Restrict writes with ownership checks using `(select auth.uid())`.
- Add both `USING` and `WITH CHECK` for update policies.
- Do not authorize from user-editable metadata.
- Do not bypass RLS with `SECURITY DEFINER` to fix permissions.
- Add indexes for foreign keys and filtered realtime columns:
  `avis.id_lieu`, `avis.id_utilisateur`.

---

## Design System

Never hardcode colors or spacing inline. Use `AppColors` and `AppSpacing`.

| Token | Value |
|---|---|
| Primary | `#0F172A` |
| Accent / Interactive | `#2563EB` |
| Background | `#F8FAFC` |
| Surface | `#FFFFFF` |
| Surface Variant | `#F1F5F9` |
| Secondary text | `#64748B` |
| Font | Inter |

---

## Logging

Use the shared logger:

```dart
import '../core/utils/logger.dart';

logger.i('Saved place');
logger.w('Invalid input');
logger.e('Save failed', error: error, stackTrace: stackTrace);
```

Do not use `print()`, `dart:developer`, or ad hoc `Logger()` instances in
production code.

---

## Code Rules

- Dart null safety required.
- No `!` force unwrap without an explicit null check above it.
- Add `///` doc comments to public classes, methods, and fields.
- Max line length: 120 characters.
- One public class per file. File name = snake_case.
- Validate inputs before Supabase writes.
- Inject sources when screens need test doubles.
- Keep Supabase types out of UI when an app-level contract is sufficient.
- Use `SupabaseDataConverter` for loose backend values.

---

## Git

- **Branch from:** `develop`
- **Branch naming:** `feat/<short-description>` or `fix/<short-description>`
- **Commit style:** `type: short description`
- **Never commit to:** `main` or `develop`
- Do not add AI-agent `Co-authored-by` trailers to commits.
- Run `flutter analyze && flutter test` before opening a PR.

---

## Out of Scope

Do not implement or suggest:

- Social features: DMs, public profiles, follows.
- E-commerce or food ordering.
- Timetables or academic schedules.
- Multi-campus support. Valenciennes campus only.

---

## Current Status

Sprint 2 implementation started. Supabase is wired.

When adding a feature:

1. Add or update a model in `lib/data/models/`.
2. Add a Supabase source in `lib/data/sources/`.
3. Apply RLS and indexes for new exposed tables.
4. Build the page or widget in `lib/pages/`.
5. Add focused tests.
6. Run `flutter analyze && flutter test`.
