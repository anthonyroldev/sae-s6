import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/core/utils/supabase_data_converter.dart';

void main() {
  group('SupabaseDataConverter', () {
    test('converts Supabase time values', () {
      expect(
        SupabaseDataConverter.toTimeOfDay('08:45:00'),
        const Duration(hours: 8, minutes: 45),
      );
    });

    test('returns open during daytime range', () {
      expect(
        SupabaseDataConverter.isOpenAt(
          currentTimestamp: DateTime(2026, 6, 2, 12),
          heureOuverture: const Duration(hours: 8),
          heureFermeture: const Duration(hours: 18),
        ),
        isTrue,
      );
    });

    test('returns open during overnight range', () {
      expect(
        SupabaseDataConverter.isOpenAt(
          currentTimestamp: DateTime(2026, 6, 2, 1),
          heureOuverture: const Duration(hours: 20),
          heureFermeture: const Duration(hours: 2),
        ),
        isTrue,
      );
    });

    test('returns open all day when times match', () {
      expect(
        SupabaseDataConverter.isOpenAt(
          currentTimestamp: DateTime(2026, 6, 2, 12),
          heureOuverture: Duration.zero,
          heureFermeture: Duration.zero,
        ),
        isTrue,
      );
    });
  });
}
