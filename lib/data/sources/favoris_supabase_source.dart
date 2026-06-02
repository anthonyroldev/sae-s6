import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/lieu.dart';
import 'favoris_source.dart';

/// Supabase source for favorite places.
class FavorisSupabaseSource implements FavorisSource {
  static const _favorisTable = 'favoris';
  static const _lieuxTable = 'lieux';
  static const _userIdColumn = 'id_utilisateur';
  static const _placeIdColumn = 'id_lieu';

  final SupabaseClient _client;

  /// Creates a Supabase favorite source.
  FavorisSupabaseSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Stream<Set<String>> watchCurrentUserPlaceIds() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value(const <String>{});
    }

    return _client
        .from(_favorisTable)
        .stream(primaryKey: [_userIdColumn, _placeIdColumn])
        .eq(_userIdColumn, userId)
        .map(
          (rows) => rows
              .map((row) => row[_placeIdColumn]?.toString() ?? '')
              .where((id) => id.isNotEmpty)
              .toSet(),
        );
  }

  @override
  Stream<List<Lieu>> watchCurrentUserPlaces() {
    return watchCurrentUserPlaceIds().asyncMap((ids) async {
      if (ids.isEmpty) {
        return const <Lieu>[];
      }

      final rows = await _client
          .from(_lieuxTable)
          .select()
          .inFilter('id', ids.toList())
          .order('nom');
      return rows.map(Lieu.fromMap).toList();
    });
  }

  @override
  Future<void> setFavorite({
    required String lieuId,
    required bool isFavorite,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw StateError('A signed-in user is required to manage favorites.');
    }

    if (isFavorite) {
      await _client.from(_favorisTable).insert({
        _userIdColumn: userId,
        _placeIdColumn: lieuId,
      });
      return;
    }

    await _client
        .from(_favorisTable)
        .delete()
        .eq(_userIdColumn, userId)
        .eq(_placeIdColumn, lieuId);
  }

  String? get _currentUserId => _client.auth.currentUser?.id;
}
