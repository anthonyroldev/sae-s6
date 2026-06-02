import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/lieu.dart';

/// Supabase source for campus places.
class LieuSupabaseSource {
  static const _table = 'lieux';

  final SupabaseClient _client;

  /// Creates a Supabase source for campus places.
  LieuSupabaseSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Watches all campus places, ordered by name.
  Stream<List<Lieu>> watchAll() {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('nom')
        .map((rows) => rows.map(Lieu.fromMap).toList());
  }

  /// Creates a campus place.
  Future<void> save(Lieu lieu) {
    _validateLieu(lieu);
    return _client.from(_table).insert(lieu.toMap());
  }

  void _validateLieu(Lieu lieu) {
    if (lieu.nom.trim().isEmpty) {
      throw ArgumentError.value(lieu.nom, 'nom');
    }
    if (lieu.latitude < -90 || lieu.latitude > 90) {
      throw ArgumentError.value(lieu.latitude, 'latitude');
    }
    if (lieu.longitude < -180 || lieu.longitude > 180) {
      throw ArgumentError.value(lieu.longitude, 'longitude');
    }
  }
}
