import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/supabase_data_converter.dart';
import '../models/avis.dart';
import '../models/avis_with_auteur.dart';
import 'avis_source.dart';

/// Supabase source for place reviews.
class AvisSupabaseSource implements AvisSource {
  static const _table = 'avis';
  static const _authorsView = 'utilisateurs_public';

  final SupabaseClient _client;

  /// Creates a Supabase source for place reviews.
  AvisSupabaseSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

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
  @override
  Future<List<AvisWithAuteur>> fetchForLieu(String idLieu, {int? limit}) async {
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
        .from(_authorsView)
        .select('id, nom')
        .inFilter('id', userIds);
    final nomById = {
      for (final r in userRows)
        SupabaseDataConverter.toStringValue(r['id']):
            SupabaseDataConverter.toStringValue(r['nom']),
    };

    return avisList.map((a) {
      final nomAuteur = nomById[a.idUtilisateur] ?? '';
      return AvisWithAuteur(
        avis: a,
        nomAuteur: nomAuteur.isEmpty ? 'Anonyme' : nomAuteur,
      );
    }).toList();
  }

  /// Returns the average note and total review count for a place.
  @override
  Future<({double average, int count})> fetchStats(String idLieu) async {
    final rows = await _client
        .from(_table)
        .select('note')
        .eq('id_lieu', idLieu)
        .eq('is_validated', true);
    if (rows.isEmpty) return (average: 0.0, count: 0);
    final sum = rows.fold<double>(
      0,
      (s, r) => s + ((r['note'] as num?)?.toDouble() ?? 0),
    );
    return (average: sum / rows.length, count: rows.length);
  }

  /// Returns the average note and total review count for each place.
  @override
  Future<Map<String, ({double average, int count})>> fetchStatsForLieux(
    List<String> idsLieu,
  ) async {
    final uniqueIds = idsLieu.where((id) => id.trim().isNotEmpty).toSet();
    if (uniqueIds.isEmpty) return const {};

    final rows = await _client
        .from(_table)
        .select('id_lieu, note')
        .inFilter('id_lieu', uniqueIds.toList())
        .eq('is_validated', true);

    final sums = <String, double>{};
    final counts = <String, int>{};
    for (final row in rows) {
      final idLieu = SupabaseDataConverter.toStringValue(row['id_lieu']);
      if (idLieu.isEmpty) continue;
      sums[idLieu] =
          (sums[idLieu] ?? 0) + SupabaseDataConverter.toDouble(row['note']);
      counts[idLieu] = (counts[idLieu] ?? 0) + 1;
    }

    return {
      for (final idLieu in sums.keys)
        idLieu: (
          average: sums[idLieu]! / counts[idLieu]!,
          count: counts[idLieu]!,
        ),
    };
  }

  @override
  Future<void> moderateReview(Avis avis) async {
    if (avis.idAvis == 0) {
      throw ArgumentError.value(avis.idAvis, 'idAvis');
    }
    await _client.functions.invoke(
      'validate-review',
      body: {'avisId': avis.idAvis},
    );
  }

  /// Adds or updates one review for a place.
  @override
  Future<Avis> save(Avis avis) async {
    _validateAvis(avis);
    final userId = currentUserId;
    if (userId == null) {
      throw StateError('Authenticated user required');
    }
    final payload = {...avis.toMap(), 'id_utilisateur': userId};

    if (avis.idAvis == 0) {
      final row = await _client.from(_table).insert(payload).select().single();
      return Avis.fromMap(row);
    }
    final row = await _client
        .from(_table)
        .update(payload)
        .eq('id_avis', avis.idAvis)
        .select()
        .single();
    return Avis.fromMap(row);
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
    if (avis.moderationStatus != 'pending' &&
        avis.moderationStatus != 'accepted' &&
        avis.moderationStatus != 'denied') {
      throw ArgumentError.value(avis.moderationStatus, 'moderationStatus');
    }
  }
}
