import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/pages/auth/login_code_page.dart';

import '../../support/fake_auth_source.dart';

void main() {
  testWidgets('verifies the entered code for the given email', (tester) async {
    final auth = FakeAuthSource();
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: LoginCodePage(email: 'a@b.com', authSource: auth),
      ),
    );

    await tester.enterText(find.byKey(const Key('code-field')), '123456');
    await tester.tap(find.byKey(const Key('verify-code-button')));
    await tester.pumpAndSettle();

    expect(auth.verifiedCodes, [
      (email: 'a@b.com', code: '123456', name: null),
    ]);
  });

  testWidgets('shows an error when the code is rejected', (tester) async {
    final auth = FakeAuthSource()..throwOnVerify = Exception('bad code');
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: LoginCodePage(email: 'a@b.com', authSource: auth),
      ),
    );

    await tester.enterText(find.byKey(const Key('code-field')), '000000');
    await tester.tap(find.byKey(const Key('verify-code-button')));
    await tester.pumpAndSettle();

    expect(find.text('Code incorrect ou expiré'), findsOneWidget);
  });

  testWidgets('resends the code without creating an account', (tester) async {
    final auth = FakeAuthSource();
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: LoginCodePage(email: 'a@b.com', authSource: auth),
      ),
    );

    await tester.tap(find.byKey(const Key('resend-code-button')));
    await tester.pumpAndSettle();

    expect(auth.sentCodes, [(email: 'a@b.com', shouldCreateUser: false)]);
  });

  testWidgets('resends a signup code with account creation enabled', (
    tester,
  ) async {
    final auth = FakeAuthSource();
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: LoginCodePage(
          email: 'student@uphf.fr',
          name: 'Jules Baron',
          shouldCreateUser: true,
          authSource: auth,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('resend-code-button')));
    await tester.pumpAndSettle();

    expect(auth.sentCodes, [
      (email: 'student@uphf.fr', shouldCreateUser: true),
    ]);
  });
}
