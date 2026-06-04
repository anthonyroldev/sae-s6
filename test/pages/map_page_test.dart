import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:le_repere/data/models/lieu.dart';
import 'package:le_repere/data/sources/location_access_exception.dart';
import 'package:le_repere/data/sources/location_source.dart';
import 'package:le_repere/pages/map_page.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  testWidgets('filters markers by selected category', (tester) async {
    final locationSource = _FakeLocationSource();

    await tester.pumpWidget(
      MaterialApp(
        home: MapPage(
          lieuxStream: Stream.value(const [
            Lieu(
              id: 'bu',
              nom: 'Bibliotheque',
              description: 'Calme',
              latitude: 50.356,
              longitude: 3.519,
              categorie: LieuCategorie.bibliotheque,
            ),
            Lieu(
              id: 'resto',
              nom: 'Restaurant',
              description: 'Repas',
              latitude: 50.357,
              longitude: 3.520,
              categorie: LieuCategorie.repas,
            ),
          ]),
          locationSource: locationSource,
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('place-marker-bu')), findsOneWidget);
    expect(find.byKey(const Key('place-marker-resto')), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('map-category-filter-bibliotheque')),
    );
    await tester.pump();

    expect(find.byKey(const Key('place-marker-bu')), findsOneWidget);
    expect(find.byKey(const Key('place-marker-resto')), findsNothing);

    await tester.tap(find.byKey(const Key('map-category-filter-')));
    await tester.pump();

    expect(find.byKey(const Key('place-marker-bu')), findsOneWidget);
    expect(find.byKey(const Key('place-marker-resto')), findsOneWidget);

    await locationSource.dispose();
  });

  testWidgets('hides the selected place panel when its category is filtered out', (
    tester,
  ) async {
    final locationSource = _FakeLocationSource();

    await tester.pumpWidget(
      MaterialApp(
        home: MapPage(
          lieuxStream: Stream.value(const [
            Lieu(
              id: 'resto',
              nom: 'Restaurant',
              description: 'Repas',
              latitude: 50.357,
              longitude: 3.520,
              categorie: LieuCategorie.repas,
            ),
          ]),
          locationSource: locationSource,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('place-marker-resto')));
    await tester.pump();

    expect(find.byTooltip('Itineraire'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('map-category-filter-bibliotheque')),
    );
    await tester.pump();

    expect(find.byTooltip('Itineraire'), findsNothing);

    await locationSource.dispose();
  });

  testWidgets('shows the current user position marker', (tester) async {
    final locationSource = _FakeLocationSource();

    await tester.pumpWidget(
      MaterialApp(
        home: MapPage(
          lieuxStream: Stream.value(const <Lieu>[]),
          locationSource: locationSource,
        ),
      ),
    );

    locationSource.add(const LatLng(50.356, 3.519));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('user-position-marker')), findsOneWidget);

    await locationSource.dispose();
  });

  testWidgets('keeps the map visible when location access fails', (
    tester,
  ) async {
    final locationSource = _FakeLocationSource();

    await tester.pumpWidget(
      MaterialApp(
        home: MapPage(
          lieuxStream: Stream.value(const <Lieu>[]),
          locationSource: locationSource,
        ),
      ),
    );

    locationSource.addError(
      const LocationAccessException('Permission de localisation refusée.'),
    );
    await tester.pump();

    expect(find.byType(MapPage), findsOneWidget);
    expect(find.text('Permission de localisation refusée.'), findsOneWidget);

    await locationSource.dispose();
  });

  testWidgets('opens navigation from the selected place panel', (tester) async {
    final locationSource = _FakeLocationSource();
    final launchedUris = <Uri>[];
    const place = Lieu(
      id: 'bu',
      nom: 'BU',
      description: 'Bibliotheque universitaire',
      latitude: 50.356,
      longitude: 3.519,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MapPage(
          lieuxStream: Stream.value(const [place]),
          locationSource: locationSource,
          navigationLauncher: (uri, {mode = LaunchMode.platformDefault}) async {
            launchedUris.add(uri);
            return true;
          },
        ),
      ),
    );

    await tester.pump();
    await tester.pump();
    await tester.tap(find.byKey(const Key('place-marker-bu')));
    await tester.pump();
    await tester.tap(find.byTooltip('Itineraire'));
    await tester.pump();

    expect(launchedUris, hasLength(1));
    expect(launchedUris.single.scheme, 'geo');
    expect(launchedUris.single.queryParameters['q'], '50.356,3.519(BU)');

    await locationSource.dispose();
  });

  testWidgets('falls back to Google Maps when the native navigation launch fails', (
    tester,
  ) async {
    final locationSource = _FakeLocationSource();
    final launchedUris = <Uri>[];
    const place = Lieu(
      id: 'ru',
      nom: 'RU',
      description: 'Restaurant universitaire',
      latitude: 50.357,
      longitude: 3.52,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MapPage(
          lieuxStream: Stream.value(const [place]),
          locationSource: locationSource,
          navigationLauncher: (uri, {mode = LaunchMode.platformDefault}) async {
            launchedUris.add(uri);
            return launchedUris.length > 1;
          },
        ),
      ),
    );

    await tester.pump();
    await tester.pump();
    await tester.tap(find.byKey(const Key('place-marker-ru')));
    await tester.pump();
    await tester.tap(find.byTooltip('Itineraire'));
    await tester.pump();

    expect(launchedUris, hasLength(2));
    expect(launchedUris.first.scheme, 'geo');
    expect(launchedUris.last.toString(), contains('google.com/maps/dir/'));
    expect(launchedUris.last.queryParameters['destination'], '50.357,3.52');

    await locationSource.dispose();
  });
}

class _FakeLocationSource implements LocationSource {
  final _controller = StreamController<LatLng>();

  @override
  Stream<LatLng> watchCurrentPosition() {
    return _controller.stream;
  }

  void add(LatLng position) {
    _controller.add(position);
  }

  void addError(Object error) {
    _controller.addError(error, StackTrace.current);
  }

  Future<void> dispose() {
    return _controller.close();
  }
}
