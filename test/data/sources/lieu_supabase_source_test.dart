import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/data/models/lieu.dart';
import 'package:le_repere/data/sources/lieu_supabase_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  // Construction never hits the network, and `save` validates synchronously
  // before touching the client, so a throwaway client is enough here.
  LieuSupabaseSource buildSource() => LieuSupabaseSource(
    client: SupabaseClient(
      'https://stub.supabase.co',
      'stub-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    ),
  );

  group('LieuSupabaseSource.save', () {
    test('rejects a blank name', () {
      expect(
        () => buildSource().save(const Lieu(nom: '   ', description: '')),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects an out-of-range latitude', () {
      expect(
        () => buildSource().save(
          const Lieu(nom: 'BU', description: '', latitude: 120),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects an out-of-range longitude', () {
      expect(
        () => buildSource().save(
          const Lieu(nom: 'BU', description: '', longitude: -200),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('LieuSupabaseSource.extensionFor', () {
    test('lowercases a real extension', () {
      expect(LieuSupabaseSource.extensionFor('photo.PNG'), 'png');
    });

    test('uses the last segment for multi-dot names', () {
      expect(LieuSupabaseSource.extensionFor('archive.tar.JPEG'), 'jpeg');
    });

    test('defaults to jpg when there is no usable extension', () {
      expect(LieuSupabaseSource.extensionFor('photo'), 'jpg');
      expect(LieuSupabaseSource.extensionFor(''), 'jpg');
    });
  });
}
