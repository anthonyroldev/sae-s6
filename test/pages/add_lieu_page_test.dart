import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/data/sources/lieu_supabase_source.dart';
import 'package:le_repere/pages/add_lieu_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  testWidgets('displays initial coordinates rounded to six decimals', (
    tester,
  ) async {
    final client = SupabaseClient('http://localhost', 'anon-key');
    addTearDown(client.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: AddLieuPage(
          initialLatitude: 50.35591234,
          initialLongitude: 3.51824567,
          lieuSource: LieuSupabaseSource(client: client),
        ),
      ),
    );

    final latitudeField = tester.widget<TextFormField>(
      find.byKey(const Key('latitude-field')),
    );
    final longitudeField = tester.widget<TextFormField>(
      find.byKey(const Key('longitude-field')),
    );

    expect(latitudeField.controller?.text, '50.355912');
    expect(longitudeField.controller?.text, '3.518246');
  });
}
