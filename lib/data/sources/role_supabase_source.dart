import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_role.dart';
import 'role_source.dart';

/// Supabase implementation of [RoleSource].
///
/// The role is delivered as the `user_role` JWT claim by the custom access
/// token hook, so it is read straight from the current session's access token —
/// no extra network round-trip.
class RoleSupabaseSource implements RoleSource {
  static const _claim = 'user_role';

  final SupabaseClient _client;
  UserRole? _cachedRole;

  /// Creates a Supabase role source.
  RoleSupabaseSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  UserRole get currentRole =>
      _cachedRole ??
      roleFromAccessToken(_client.auth.currentSession?.accessToken);

  @override
  Stream<UserRole> get roleChanges async* {
    yield await _resolveCurrentRole(_client.auth.currentSession);
    await for (final state in _client.auth.onAuthStateChange) {
      yield await _resolveCurrentRole(state.session);
    }
  }

  @override
  Future<void> setUserRole({required String userId, required UserRole role}) {
    return _client.rpc<void>(
      'set_user_role',
      params: {'target_user': userId, 'new_role': role.value},
    );
  }

  /// Extracts the [UserRole] carried by a Supabase access [token].
  ///
  /// Returns [UserRole.utilisateur] when the token is null, malformed, or
  /// carries no `user_role` claim.
  static UserRole roleFromAccessToken(String? token) {
    if (token == null) {
      return UserRole.utilisateur;
    }
    return UserRole.fromValue(_claimFromJwt(token, _claim));
  }

  static Object? _claimFromJwt(String token, String claim) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }
    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = json.decode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded[claim];
      }
    } on Object {
      return null;
    }
    return null;
  }

  Future<UserRole> _resolveCurrentRole(Session? session) async {
    final userId = session?.user.id;
    if (userId == null) {
      return _cacheRole(UserRole.utilisateur);
    }

    try {
      final row = await _client
          .from('utilisateurs')
          .select('role')
          .eq('id', userId)
          .maybeSingle();
      return _cacheRole(UserRole.fromValue(row?['role']));
    } on Object {
      return _cacheRole(roleFromAccessToken(session?.accessToken));
    }
  }

  UserRole _cacheRole(UserRole role) {
    _cachedRole = role;
    return role;
  }
}
