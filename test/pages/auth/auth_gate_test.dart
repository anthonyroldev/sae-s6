import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/pages/auth/auth_gate.dart';
import 'package:le_repere/pages/auth/login_email_page.dart';

import '../../support/fake_auth_source.dart';

void main() {
  testWidgets('shows the login page when signed out', (tester) async {
    final auth = FakeAuthSource();
    addTearDown(auth.dispose);

    await tester.pumpWidget(MaterialApp(home: AuthGate(authSource: auth)));
    await tester.pump();

    expect(find.byType(LoginEmailPage), findsOneWidget);
  });
}
