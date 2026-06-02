import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/pages/auth/login_email_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../support/fake_auth_source.dart';

void main() {
  testWidgets('login submits normalized email and password', (tester) async {
    final auth = FakeAuthSource();
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LoginEmailPage(authSource: auth)),
    );

    await tester.enterText(
      find.byKey(const Key('email-field')),
      ' Student@Example.com ',
    );
    await tester.enterText(
      find.byKey(const Key('password-field')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('auth-submit-button')));
    await tester.pumpAndSettle();

    expect(auth.signIns, [
      (email: 'student@example.com', password: 'password123'),
    ]);
  });

  testWidgets('rejects an invalid email', (tester) async {
    final auth = FakeAuthSource();
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LoginEmailPage(authSource: auth)),
    );

    await tester.enterText(find.byKey(const Key('email-field')), 'nope');
    await tester.enterText(
      find.byKey(const Key('password-field')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('auth-submit-button')));
    await tester.pumpAndSettle();

    expect(auth.signIns, isEmpty);
    expect(find.text('Adresse email invalide'), findsOneWidget);
  });

  testWidgets('signup reveals the name field and changes the action', (
    tester,
  ) async {
    final auth = FakeAuthSource();
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LoginEmailPage(authSource: auth)),
    );

    await tester.tap(find.byKey(const Key('signup-mode-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('name-field')), findsOneWidget);
    expect(find.text('Créer mon compte'), findsOneWidget);
  });

  testWidgets('signup rejects an empty name', (tester) async {
    final auth = FakeAuthSource();
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LoginEmailPage(authSource: auth)),
    );

    await tester.tap(find.byKey(const Key('signup-mode-button')));
    await tester.enterText(
      find.byKey(const Key('email-field')),
      'student@uphf.fr',
    );
    await tester.enterText(
      find.byKey(const Key('password-field')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('auth-submit-button')));
    await tester.pumpAndSettle();

    expect(auth.signUps, isEmpty);
    expect(find.text('Nom requis'), findsOneWidget);
  });

  testWidgets('signup rejects a non-university email', (tester) async {
    final auth = FakeAuthSource();
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LoginEmailPage(authSource: auth)),
    );

    await tester.tap(find.byKey(const Key('signup-mode-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('name-field')), 'Jules Baron');
    await tester.enterText(
      find.byKey(const Key('email-field')),
      'student@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('password-field')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('auth-submit-button')));
    await tester.pumpAndSettle();

    expect(auth.signUps, isEmpty);
    expect(
      find.text('Utilisez une adresse email universitaire'),
      findsOneWidget,
    );
  });

  testWidgets('rejects a password shorter than eight characters', (
    tester,
  ) async {
    final auth = FakeAuthSource();
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LoginEmailPage(authSource: auth)),
    );

    await tester.enterText(find.byKey(const Key('email-field')), 'a@b.com');
    await tester.enterText(find.byKey(const Key('password-field')), 'short');
    await tester.tap(find.byKey(const Key('auth-submit-button')));
    await tester.pumpAndSettle();

    expect(auth.signIns, isEmpty);
    expect(find.text('Mot de passe: 8 caractères minimum'), findsOneWidget);
  });

  testWidgets('signup submits normalized fields', (tester) async {
    final auth = FakeAuthSource();
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LoginEmailPage(authSource: auth)),
    );

    await tester.tap(find.byKey(const Key('signup-mode-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('name-field')),
      ' Jules Baron ',
    );
    await tester.enterText(
      find.byKey(const Key('email-field')),
      ' Student@Etu.Univ-Lille.fr ',
    );
    await tester.enterText(
      find.byKey(const Key('password-field')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('auth-submit-button')));
    await tester.pumpAndSettle();

    expect(auth.signUps, [
      (
        email: 'student@etu.univ-lille.fr',
        password: 'password123',
        name: 'Jules Baron',
      ),
    ]);
  });

  testWidgets('shows an error when login fails', (tester) async {
    final auth = FakeAuthSource()..throwOnSignIn = Exception('network');
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LoginEmailPage(authSource: auth)),
    );

    await tester.enterText(find.byKey(const Key('email-field')), 'a@b.com');
    await tester.enterText(
      find.byKey(const Key('password-field')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('auth-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Échec de la connexion'), findsOneWidget);
  });

  testWidgets('shows an error when signup fails', (tester) async {
    final auth = FakeAuthSource()..throwOnSignUp = Exception('network');
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LoginEmailPage(authSource: auth)),
    );

    await tester.tap(find.byKey(const Key('signup-mode-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('name-field')), 'Jules Baron');
    await tester.enterText(
      find.byKey(const Key('email-field')),
      'student@uphf.fr',
    );
    await tester.enterText(
      find.byKey(const Key('password-field')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('auth-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Échec de la création du compte'), findsOneWidget);
  });

  testWidgets('shows Supabase auth errors', (tester) async {
    final auth = FakeAuthSource()
      ..throwOnSignIn = const AuthException('Email not confirmed');
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LoginEmailPage(authSource: auth)),
    );

    await tester.enterText(find.byKey(const Key('email-field')), 'a@b.com');
    await tester.enterText(
      find.byKey(const Key('password-field')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('auth-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Email not confirmed'), findsOneWidget);
  });
}
