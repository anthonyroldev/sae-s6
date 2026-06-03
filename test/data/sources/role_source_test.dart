import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/data/models/user_role.dart';
import 'package:le_repere/data/sources/role_supabase_source.dart';

/// Builds a minimal (unsigned) JWT carrying [payload] as its claims.
String _fakeJwt(Map<String, dynamic> payload) {
  String segment(Map<String, dynamic> map) =>
      base64Url.encode(utf8.encode(json.encode(map))).replaceAll('=', '');
  final header = segment({'alg': 'HS256', 'typ': 'JWT'});
  final body = segment(payload);
  return '$header.$body.signature';
}

void main() {
  group('RoleSupabaseSource.roleFromAccessToken', () {
    test('reads the user_role claim', () {
      final token = _fakeJwt({'sub': 'abc', 'user_role': 'admin'});
      expect(RoleSupabaseSource.roleFromAccessToken(token), UserRole.admin);
    });

    test('reads each known role', () {
      for (final role in UserRole.values) {
        final token = _fakeJwt({'user_role': role.value});
        expect(RoleSupabaseSource.roleFromAccessToken(token), role);
      }
    });

    test('defaults to utilisateur when the claim is absent', () {
      final token = _fakeJwt({'sub': 'abc'});
      expect(RoleSupabaseSource.roleFromAccessToken(token), UserRole.utilisateur);
    });

    test('defaults to utilisateur for a null token', () {
      expect(RoleSupabaseSource.roleFromAccessToken(null), UserRole.utilisateur);
    });

    test('defaults to utilisateur for a malformed token', () {
      expect(RoleSupabaseSource.roleFromAccessToken('not-a-jwt'), UserRole.utilisateur);
      expect(
        RoleSupabaseSource.roleFromAccessToken('only.two'),
        UserRole.utilisateur,
      );
    });
  });
}
