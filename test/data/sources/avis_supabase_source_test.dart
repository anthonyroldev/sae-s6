import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/data/models/avis.dart';
import 'package:le_repere/data/sources/avis_supabase_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  AvisSupabaseSource buildSource() => AvisSupabaseSource(
    client: SupabaseClient(
      'https://stub.supabase.co',
      'stub-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    ),
  );

  group('AvisSupabaseSource.save', () {
    test('rejects invalid moderation status before network access', () {
      expect(
        () => buildSource().save(
          Avis(
            note: 4,
            commentaire: 'Bon lieu.',
            date: DateTime(2026),
            idLieu: 'lieu-1',
            idUtilisateur: 'user-1',
            moderationStatus: 'unknown',
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('AvisSupabaseSource.moderateReview', () {
    test('rejects missing review id before network access', () {
      expect(
        () => buildSource().moderateReview(
          Avis.create(
            note: 4,
            commentaire: 'Bon lieu.',
            idLieu: 'lieu-1',
            idUtilisateur: 'user-1',
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
