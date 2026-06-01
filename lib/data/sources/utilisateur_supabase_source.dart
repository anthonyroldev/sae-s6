import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/utilisateur.dart';

/// Supabase source for app users.
///
/// Users are keyed by their Firebase Auth UID, which links each Supabase row
/// to the authenticated account.
class UtilisateurSupabaseSource {
  static const _table = 'utilisateurs';

  final SupabaseClient _client;

  /// Creates a Supabase source for app users.
  UtilisateurSupabaseSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Watches one user by identifier (Firebase UID).
  Stream<Utilisateur?> watchById(String id) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((rows) => rows.isEmpty ? null : Utilisateur.fromMap(rows.first));
  }

  /// Fetches one user by identifier (Firebase UID).
  Future<Utilisateur?> getById(String id) async {
    final row = await _client.from(_table).select().eq('id', id).maybeSingle();
    return row == null ? null : Utilisateur.fromMap(row);
  }

  /// Creates or updates a user.
  Future<void> save(Utilisateur utilisateur) {
    return _client.from(_table).upsert(utilisateur.toMap());
  }
}
