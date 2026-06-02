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
  Future<void> soumettre(PropositionLieu proposition) {
    final payload = proposition.toInsertMap();
    final userId = _client.auth.currentUser?.id;
    if (userId != null) {
      payload['id_utilisateur'] = userId;
    }
    return _client.from(_table).insert(payload);
  }

  @override
  Stream<List<PropositionLieu>> watchEnAttente() {
    return _client
        .from(_table)
        .stream(primaryKey: ['id_proposition'])
        .order('created_at')
        .map(
          (rows) => rows
              .map(PropositionLieu.fromMap)
              .where((p) => p.statut == PropositionStatut.enAttente)
              .toList(growable: false),
        );
  }

  @override
  Future<void> valider(int id) {
    return _client.rpc<void>('valider_proposition', params: {'p_id': id});
  }

  @override
  Future<void> refuser(int id) {
    return _client.rpc<void>('refuser_proposition', params: {'p_id': id});
  }
}
