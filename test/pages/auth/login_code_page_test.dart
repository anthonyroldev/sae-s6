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

    expect(auth.verifiedCodes, [(email: 'a@b.com', code: '123456')]);
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

  testWidgets('resends the code', (tester) async {
    final auth = FakeAuthSource();
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: LoginCodePage(email: 'a@b.com', authSource: auth),
      ),
    );

    await tester.tap(find.byKey(const Key('resend-code-button')));
    await tester.pumpAndSettle();

    expect(auth.sentCodes, ['a@b.com']);
  });
}
