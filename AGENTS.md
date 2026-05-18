# AGENTS.md — Le Repère

Flutter mobile app for discovering campus places at INSA Hauts-de-France.
Team of 5 · Scrum · Dart/Flutter · Firebase · Riverpod

---

## Environment

- **Flutter SDK:** stable channel — run `flutter --version` to confirm
- **Dart:** included with Flutter, no separate install
- **Target platforms:** Android + iOS
- **Package manager:** `pub` (via `flutter pub`)

Do NOT use `npm`, `pip`, or any non-Dart tooling unless explicitly asked.

---

## Commands

### Setup
```bash
flutter pub get
```

### Run
```bash
flutter run                          # requires connected device or emulator
flutter run -d chrome                # web fallback if no device available
```

### Build
```bash
flutter build apk --debug            # Android debug
flutter build ios --debug --no-codesign  # iOS debug (CI only)
```

### Analyze (run before every commit)
```bash
flutter analyze
```
Zero warnings policy. Fix all issues before considering a task done.

### Test
```bash
flutter test                         # unit + widget tests
flutter test --coverage              # with coverage report
```

### Format
```bash
dart format lib/ test/
```

---

## Project Structure

```
lib/
├── core/
│   ├── constants/     # app-wide constants (colors, strings, sizes)
│   ├── theme/         # ThemeData, TextStyles, ColorScheme
│   └── utils/         # helper functions, extensions
├── data/
│   ├── models/        # JSON-serializable data classes
│   ├── repositories/  # concrete implementations of domain interfaces
│   └── sources/       # Firebase/Firestore data sources
├── domain/
│   ├── entities/      # pure Dart business objects (no Flutter, no Firebase)
│   ├── interfaces/    # abstract repository contracts
│   └── usecases/      # single-responsibility use case classes
└── presentation/
    ├── screens/       # one folder per screen
    ├── widgets/       # shared reusable widgets
    └── providers/     # Riverpod providers
```

**Rule:** no Flutter or Firebase imports in `domain/`. Entities and use cases are pure Dart.

---

## Architecture

Layered architecture — strict dependency direction:

```
presentation → domain ← data
```

- `presentation` depends on `domain` (via providers calling use cases)
- `data` depends on `domain` (implements interfaces)
- `domain` depends on nothing

When adding a feature:
1. Define the entity in `domain/entities/`
2. Define the repository interface in `domain/interfaces/`
3. Write the use case in `domain/usecases/`
4. Implement the repository in `data/repositories/`
5. Wire the Firestore source in `data/sources/`
6. Create the Riverpod provider in `presentation/providers/`
7. Build the screen/widget in `presentation/screens/`

---

## State Management

**Riverpod only.** Do not use `setState`, `Provider` (the old package), `Bloc`, or `GetX`.

```dart
// Define
final placesProvider = StreamProvider<List<Place>>((ref) {
  return ref.read(placeRepositoryProvider).watchAll();
});

// Consume
class PlaceListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placesProvider);
    return places.when(
      data: (list) => ...,
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text(e.toString()),
    );
  }
}
```

---

## Design System

All visual constants are defined in `lib/core/constants/` and `lib/core/theme/`. Never hardcode colors, font sizes, or spacing inline.

| Token | Value |
|---|---|
| Primary | `#0F172A` |
| Accent / Interactive | `#2563EB` |
| Background | `#F8FAFC` |
| Surface | `#FFFFFF` |
| Surface Variant | `#F1F5F9` |
| Secondary text | `#64748B` |
| Font | Inter |

```dart
// Correct
color: AppColors.accent

// Wrong
color: Color(0xFF2563EB)
```

---

## Firebase

- **Firestore** for place data, reviews, and news
- **Firebase Auth** for user authentication (email/password)

Collections:
```
places/         { name, description, category, lat, lng, openingHours }
places/{id}/reviews/    { userId, rating, comment, createdAt }
places/{id}/news/       { userId, content, createdAt, expiresAt }
users/          { uid, displayName, email }
```

Never expose Firebase config keys in code. Use `.env` or `--dart-define`.

---

## Code Rules

- **Dart null safety** is enabled. No `!` force-unwrap without an explicit null check above it.
- All public classes, methods, and fields must have a doc comment (`///`).
- No `print()` in production code — use a logger.
- Max line length: 120 characters (`dart format` enforces this).
- One class per file. File name = snake_case of class name.
- No business logic in widgets. Widgets only call providers and render state.

---

## Git

- **Branch from:** `develop`
- **Branch naming:** `feature/<short-description>` or `fix/<short-description>`
- **Commit style:** `type: short description` (e.g. `feat: add place list screen`, `fix: open hours null crash`)
- **Never commit to:** `main` or `develop` directly — both are protected, PR required
- Run `flutter analyze && flutter test` before opening a PR

---

## Out of Scope

Do not implement or suggest:
- Social features (DMs, public profiles, follows)
- E-commerce or food ordering
- Timetables or academic schedules
- Multi-campus support (Valenciennes campus only)

---

## Current Sprint (Sprint 1 — week 21)

Deliverable due **22/05/2026**: Figma mockup + Vision Produit. No feature code expected yet.

Sprint 2 (week 23) delivers the working Flutter app.

If asked to implement a feature, scaffold it in the correct layer but do not wire Firebase until Sprint 2 is confirmed started.
