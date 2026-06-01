import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/pages/auth/login_code_page.dart';
import 'package:le_repere/pages/auth/login_email_page.dart';

import '../../support/fake_auth_source.dart';

void main() {
  testWidgets('sends a code and navigates to the code page', (tester) async {
    final auth = FakeAuthSource();
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LoginEmailPage(authSource: auth)),
    );

    await tester.enterText(
      find.byKey(const Key('email-field')),
      'student@insa.fr',
    );
    await tester.tap(find.byKey(const Key('send-code-button')));
    await tester.pumpAndSettle();

    expect(auth.sentCodes, ['student@insa.fr']);
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
    expect(find.text('Email invalide'), findsOneWidget);
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
