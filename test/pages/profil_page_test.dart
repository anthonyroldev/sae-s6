import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/pages/profil_page.dart';

import '../support/fake_auth_source.dart';

void main() {
  testWidgets('tapping Déconnexion signs out', (tester) async {
    final auth = FakeAuthSource();
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(home: ProfilPage(authSource: auth)),
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
    await tester.pump();
    await tester.tap(find.text('Déconnexion'));
    await tester.pump();

    expect(auth.signOutCount, 1);
  });
}
