import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/pages/add_lieu_page.dart';

import '../support/fake_proposition_source.dart';

void main() {
  testWidgets('displays initial coordinates rounded to six decimals', (
    tester,
  ) async {
    final propositionSource = FakePropositionSource();
    addTearDown(propositionSource.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: AddLieuPage(
          propositionSource: propositionSource,
          initialLatitude: 50.35591234,
          initialLongitude: 3.51824567,
        ),
      ),
    );

    final latitudeField = tester.widget<TextFormField>(
      find.descendant(
        of: find.byKey(const Key('latitude-field')),
        matching: find.byType(TextFormField),
      ),
    );
    final longitudeField = tester.widget<TextFormField>(
      find.descendant(
        of: find.byKey(const Key('longitude-field')),
        matching: find.byType(TextFormField),
      ),
    );

    expect(latitudeField.controller?.text, '50.355912');
    expect(longitudeField.controller?.text, '3.518246');
  });
}
