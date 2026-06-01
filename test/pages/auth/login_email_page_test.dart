import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/pages/auth/login_code_page.dart';
import 'package:le_repere/pages/auth/login_email_page.dart';

import '../../support/fake_auth_source.dart';

void main() {
  testWidgets('login sends a code without creating an account', (tester) async {
    final auth = FakeAuthSource();
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LoginEmailPage(authSource: auth)),
    );

    await tester.enterText(
      find.byKey(const Key('email-field')),
      'student@example.com',
    );
    await tester.tap(find.byKey(const Key('send-code-button')));
    await tester.pumpAndSettle();

    expect(auth.sentCodes, [
      (email: 'student@example.com', shouldCreateUser: false),
    ]);
    expect(find.byType(LoginCodePage), findsOneWidget);
  });

  testWidgets('rejects an invalid email without sending', (tester) async {
    final auth = FakeAuthSource();
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LoginEmailPage(authSource: auth)),
    );

    await tester.enterText(find.byKey(const Key('email-field')), 'nope');
    await tester.tap(find.byKey(const Key('send-code-button')));
    await tester.pumpAndSettle();

    expect(auth.sentCodes, isEmpty);
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
    await tester.tap(find.byKey(const Key('send-code-button')));
    await tester.pumpAndSettle();

    expect(auth.sentCodes, isEmpty);
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
    await tester.tap(find.byKey(const Key('send-code-button')));
    await tester.pumpAndSettle();

    expect(auth.sentCodes, isEmpty);
    expect(
      find.text('Utilisez une adresse email universitaire'),
      findsOneWidget,
    );
  });

  testWidgets('signup sends a code and passes the name to verification', (
    tester,
  ) async {
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
      'student@etu.univ-lille.fr',
    );
    await tester.tap(find.byKey(const Key('send-code-button')));
    await tester.pumpAndSettle();

    expect(auth.sentCodes, [
      (email: 'student@etu.univ-lille.fr', shouldCreateUser: true),
    ]);
    await tester.enterText(find.byKey(const Key('code-field')), '123456');
    await tester.tap(find.byKey(const Key('verify-code-button')));
    await tester.pumpAndSettle();

    expect(auth.verifiedCodes, [
      (email: 'student@etu.univ-lille.fr', code: '123456', name: 'Jules Baron'),
    ]);
  });

  testWidgets('shows an error when sending the code fails', (tester) async {
    final auth = FakeAuthSource()..throwOnSend = Exception('network');
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LoginEmailPage(authSource: auth)),
    );

    await tester.enterText(find.byKey(const Key('email-field')), 'a@b.com');
    await tester.tap(find.byKey(const Key('send-code-button')));
    await tester.pumpAndSettle();

    expect(find.text("Échec de l'envoi du code"), findsOneWidget);
  });
}
