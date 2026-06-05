import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/data/models/lieu.dart';
import 'package:le_repere/pages/add_avis_page.dart';

import '../support/fake_avis_source.dart';
import '../support/fake_review_notification_source.dart';

void main() {
  testWidgets('saves pending review and starts moderation without waiting', (
    tester,
  ) async {
    final avisSource = FakeAvisSource();
    final notificationSource = FakeReviewNotificationSource();

    await tester.pumpWidget(
      MaterialApp(
        home: AddAvisPage(
          lieu: const Lieu(id: 'lieu-1', nom: 'BU', description: ''),
          avisSource: avisSource,
          notificationSource: notificationSource,
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
    expect(notificationSource.shown, isEmpty);
  });

  testWidgets('shows local notification when moderation accepts review', (
    tester,
  ) async {
    final avisSource = FakeAvisSource();
    final notificationSource = FakeReviewNotificationSource();

    await tester.pumpWidget(
      MaterialApp(
        home: AddAvisPage(
          lieu: const Lieu(id: 'lieu-1', nom: 'BU', description: ''),
          avisSource: avisSource,
          notificationSource: notificationSource,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.star_border).at(3));
    await tester.enterText(find.byType(TextField), 'Très bon lieu.');
    await tester.tap(find.text('Publier mon avis'));
    await tester.pump();

    avisSource.moderationCompleter.complete('accepted');
    await tester.pump();

    expect(notificationSource.shown, [(reviewId: 42, status: 'accepted')]);
  });

  testWidgets('shows local notification when moderation denies review', (
    tester,
  ) async {
    final avisSource = FakeAvisSource();
    final notificationSource = FakeReviewNotificationSource();

    await tester.pumpWidget(
      MaterialApp(
        home: AddAvisPage(
          lieu: const Lieu(id: 'lieu-1', nom: 'BU', description: ''),
          avisSource: avisSource,
          notificationSource: notificationSource,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.star_border).at(3));
    await tester.enterText(find.byType(TextField), 'Très bon lieu.');
    await tester.tap(find.text('Publier mon avis'));
    await tester.pump();

    avisSource.moderationCompleter.complete('denied');
    await tester.pump();

    expect(notificationSource.shown, [(reviewId: 42, status: 'denied')]);
  });
}
