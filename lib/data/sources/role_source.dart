import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_role.dart';

/// Reads and manages the authenticated user's application role.
///
/// The role is delivered as the `user_role` JWT claim by the Supabase custom
/// access token hook, so it is read straight from the current session's access
/// token — no extra network round-trip.
class RoleSource {
  static const _claim = 'user_role';

  final SupabaseClient _client;

  /// Creates a role source.
  RoleSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// The current user's role, or [UserRole.utilisateur] when signed out.
  UserRole get currentRole =>
      roleFromAccessToken(_client.auth.currentSession?.accessToken);

  /// Emits the user's role whenever the auth state changes.
  Stream<UserRole> get roleChanges => _client.auth.onAuthStateChange.map(
    (state) => roleFromAccessToken(state.session?.accessToken),
  );

  /// Promotes or demotes [userId] to [role].
  ///
  /// Backed by the `set_user_role` RPC, which rejects callers that are not
  /// administrators.
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
}
