# Le Repere

Flutter app for discovering places on Valenciennes for students.
It uses Firebase for data storage and authentication.

## Prerequisites

- Flutter SDK stable
- Android Studio or Xcode for mobile targets
- 
Check install:

```bash
flutter --version
flutter doctor
```

## Init

From repo root:

```bash
flutter pub get
```

Firebase config files are already present:

- `lib/firebase_options.dart`
- `android/app/google-services.json`

## Launch

List available devices:

```bash
flutter devices
```

Run on connected device or emulator:

```bash
flutter run
```

Run on Chrome:

```bash
flutter run -d chrome
```

Run on a specific device:

```bash
flutter run -d <device-id>
```

## Quality Checks

Format:

```bash
dart format lib/ test/
```

Analyze:

```bash
flutter analyze
```

Test:

```bash
flutter test
```

## Debug Builds

Android:

```bash
flutter build apk --debug
```

iOS without signing:

```bash
flutter build ios --debug --no-codesign
```
