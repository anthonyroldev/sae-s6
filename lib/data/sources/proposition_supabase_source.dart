import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/proposition_lieu.dart';
import 'proposition_source.dart';

/// Supabase implementation of [PropositionSource].
class PropositionSupabaseSource implements PropositionSource {
  static const _table = 'propositions_lieu';

  final SupabaseClient _client;

  /// Creates a Supabase source for place proposals.
  PropositionSupabaseSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<void> soumettre(PropositionLieu proposition) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Utilisateur non connecte');
    }

    final idLieu = _newPendingLieuId(userId);
    await _client
        .from('lieux')
        .insert(proposition.toLieu().copyWith(id: idLieu).toMap());

    final payload = proposition.copyWithIdLieu(idLieu).toInsertMap();
    payload['id_utilisateur'] = userId;
    await _client.from(_table).insert(payload);
  }

  @override
  Stream<List<PropositionLieu>> watchEnAttente() {
    return _client
        .from(_table)
        .stream(primaryKey: ['id_proposition'])
        .order('created_at')
        .asyncMap(_withLinkedPlaces);
  }

  @override
  Future<void> valider(int id) async {
    final userId = _client.auth.currentUser?.id;
    final row = await _client
        .from(_table)
        .select('id_lieu')
        .eq('id_proposition', id)
        .single();
    final idLieu = row['id_lieu']?.toString();

    await _client
        .from(_table)
        .update({
          'statut': PropositionStatut.validee.value,
          'id_administrateur': ?userId,
        })
        .eq('id_proposition', id);
    if (idLieu != null && idLieu.isNotEmpty) {
      await _client
          .from('lieux')
          .update({'is_validated': true})
          .eq('id', idLieu);
    }
  }

  @override
  Future<void> refuser(int id) {
    final userId = _client.auth.currentUser?.id;
    return _client
        .from(_table)
        .update({
          'statut': PropositionStatut.refusee.value,
          'id_administrateur': ?userId,
        })
        .eq('id_proposition', id);
  }

  Future<List<PropositionLieu>> _withLinkedPlaces(
    List<Map<String, dynamic>> rows,
  ) async {
    final pendingRows = rows
        .where(
          (row) =>
              PropositionStatut.fromValue(row['statut']) ==
              PropositionStatut.enAttente,
        )
        .toList(growable: false);
    final ids = pendingRows
        .map((row) => row['id_lieu']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (ids.isEmpty) {
      return pendingRows.map(PropositionLieu.fromMap).toList(growable: false);
    }

    final lieuRows = await _client.from('lieux').select().inFilter('id', ids);
    final lieuxById = {
      for (final row in lieuRows) row['id']?.toString() ?? '': row,
    };
    return pendingRows
        .map((row) {
          final idLieu = row['id_lieu']?.toString() ?? '';
          return PropositionLieu.fromMap({
            ...row,
            if (lieuxById.containsKey(idLieu)) 'lieux': lieuxById[idLieu],
          });
        })
        .toList(growable: false);
  }

  String _newPendingLieuId(String userId) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final compactUserId = userId.replaceAll('-', '');
    final userPart = compactUserId.length <= 8
        ? compactUserId
        : compactUserId.substring(0, 8);
    return 'proposition-$timestamp-$userPart';
  }
}
