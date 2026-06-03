import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/data/models/lieu.dart';
import 'package:le_repere/pages/feed_page.dart';

import '../support/fake_favoris_source.dart';
import '../support/fake_lieu_source.dart';

void main() {
  Widget buildFeed({
    required List<Lieu> places,
    FakeFavorisSource? favorisSource,
  }) {
    return MaterialApp(
      home: FeedPage(
        lieuSource: FakeLieuSource(places),
        favorisSource:
            favorisSource ??
            FakeFavorisSource(idsStream: Stream.value(const <String>{})),
      ),
    );
  }

  testWidgets('renders a place coming from the source', (tester) async {
    await tester.pumpWidget(
      buildFeed(
        places: const [Lieu(nom: 'Bibliothèque', description: 'Calme')],
      ),
    );
    await tester.pump();

    expect(find.text('Bibliothèque'), findsOneWidget);
  });

  testWidgets('shows an empty state when there is no place', (tester) async {
    await tester.pumpWidget(buildFeed(places: const []));
    await tester.pump();

    expect(find.text('Aucun lieu trouve'), findsOneWidget);
  });

  testWidgets('toggling a favorite forwards the change to the source', (
    tester,
  ) async {
    final favorisSource = FakeFavorisSource(
      idsStream: Stream.value(const <String>{}),
    );
    await tester.pumpWidget(
      buildFeed(
        places: const [Lieu(id: 'bu', nom: 'BU', description: 'Calme')],
        favorisSource: favorisSource,
      ),
    );
    await tester.pump();

    final favoriteButton = find.byTooltip('Ajouter aux favoris');
    await tester.ensureVisible(favoriteButton);
    await tester.pump();
    await tester.tap(favoriteButton);
    await tester.pump();

    expect(favorisSource.updates, hasLength(1));
    expect(favorisSource.updates.single.lieuId, 'bu');
    expect(favorisSource.updates.single.isFavorite, isTrue);
  });
}
