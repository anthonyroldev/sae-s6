import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/avis.dart';
import '../models/avis_with_auteur.dart';
import '../models/avis_with_lieu.dart';

/// Supabase source for place reviews.
class AvisSupabaseSource {
  static const _table = 'avis';

  final SupabaseClient _client;

  /// Creates a Supabase source for place reviews.
  AvisSupabaseSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Watches reviews for a place, newest first.
  Stream<List<Avis>> watchForLieu(String idLieu) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id_avis'])
        .eq('id_lieu', idLieu)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(Avis.fromMap).toList());
  }

  /// Fetches reviews with author names for a place, newest first.
  Future<List<AvisWithAuteur>> fetchForLieu(
    String idLieu, {
    int? limit,
  }) async {
    final query = _client
        .from(_table)
        .select()
        .eq('id_lieu', idLieu)
        .order('created_at', ascending: false);
    final rows = limit != null ? await query.limit(limit) : await query;
    if (rows.isEmpty) return [];

    final avisList = rows.map(Avis.fromMap).toList();

    final userIds = avisList.map((a) => a.idUtilisateur).toSet().toList();
    final userRows = await _client
        .from('utilisateurs')
        .select('id, nom')
        .inFilter('id', userIds);
    final nomById = {
      for (final r in userRows)
        r['id'] as String: (r['nom'] as String?) ?? 'Anonyme',
    };

    return avisList
        .map(
          (a) => AvisWithAuteur(
            avis: a,
            nomAuteur: nomById[a.idUtilisateur] ?? 'Anonyme',
          ),
        )
        .toList();
  }

  /// Returns the average note and total review count for a place.
  Future<({double average, int count})> fetchStats(String idLieu) async {
    final rows = await _client
        .from(_table)
        .select('note')
        .eq('id_lieu', idLieu);
    if (rows.isEmpty) return (average: 0.0, count: 0);
    final sum = rows.fold<int>(0, (s, r) => s + ((r['note'] as num?)?.toInt() ?? 0));
    return (average: sum / rows.length, count: rows.length);
  }

  /// Fetches all reviews posted by the current user, with the place name.
  Future<List<AvisWithLieu>> fetchForCurrentUser() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final rows = await _client
        .from(_table)
        .select()
        .eq('id_utilisateur', userId)
        .order('created_at', ascending: false);
    if (rows.isEmpty) return [];

    final avisList = rows.map(Avis.fromMap).toList();
    final lieuIds = avisList.map((a) => a.idLieu).toSet().toList();

    final lieuRows = await _client
        .from('lieux')
        .select('id, nom')
        .inFilter('id', lieuIds);
    final nomById = {
      for (final r in lieuRows)
        r['id'] as String: (r['nom'] as String?) ?? 'Lieu inconnu',
    };

    return avisList
        .map((a) => AvisWithLieu(avis: a, nomLieu: nomById[a.idLieu] ?? 'Lieu inconnu'))
        .toList();
  }

  /// Adds or updates one review for a place.
  Future<void> save(Avis avis) {
    _validateAvis(avis);
    if (avis.idAvis == 0) {
      return _client.from(_table).insert(avis.toMap());
    }
    return _client.from(_table).update(avis.toMap()).eq('id_avis', avis.idAvis);
  }

  void _validateAvis(Avis avis) {
    if (avis.idLieu.trim().isEmpty) {
      throw ArgumentError.value(avis.idLieu, 'idLieu');
    }
    if (avis.idUtilisateur.trim().isEmpty) {
      throw ArgumentError.value(avis.idUtilisateur, 'idUtilisateur');
    }
    if (avis.note < 1 || avis.note > 5) {
      throw ArgumentError.value(avis.note, 'note');
    }
    if (avis.commentaire.trim().isEmpty) {
      throw ArgumentError.value(avis.commentaire, 'commentaire');
    }
  }
}
