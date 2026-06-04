import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/data/models/lieu.dart';
import 'package:le_repere/pages/add_avis_page.dart';

import '../support/fake_avis_source.dart';

void main() {
  testWidgets('saves pending review and starts moderation without waiting', (
    tester,
  ) async {
    final avisSource = FakeAvisSource();

    await tester.pumpWidget(
      MaterialApp(
        home: AddAvisPage(
          lieu: const Lieu(id: 'lieu-1', nom: 'BU', description: ''),
          avisSource: avisSource,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.star_border).at(3));
    await tester.enterText(find.byType(TextField), 'Très bon lieu.');
    await tester.tap(find.text('Publier mon avis'));
    await tester.pump();

    expect(avisSource.saved, hasLength(1));
    expect(avisSource.saved.single.isValidated, isFalse);
    expect(avisSource.saved.single.moderationStatus, 'pending');
    expect(avisSource.moderatedAvis?.idAvis, 42);
    expect(avisSource.moderationCompleted, isFalse);
    expect(find.text('Avis envoyé. Validation en attente.'), findsOneWidget);
  });
}
