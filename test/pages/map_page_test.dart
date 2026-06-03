import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:le_repere/data/models/lieu.dart';
import 'package:le_repere/data/sources/location_access_exception.dart';
import 'package:le_repere/data/sources/location_source.dart';
import 'package:le_repere/pages/map_page.dart';

void main() {
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
