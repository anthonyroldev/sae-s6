import 'dart:async';

import 'package:le_repere/data/models/avis.dart';
import 'package:le_repere/data/models/avis_with_auteur.dart';
import 'package:le_repere/data/sources/avis_source.dart';

class FakeAvisSource implements AvisSource {
  final Completer<void> moderationCompleter = Completer<void>();
  final List<Avis> saved = [];
  Avis? moderatedAvis;

  @override
  String? currentUserId = 'user-1';

  bool get moderationCompleted => moderationCompleter.isCompleted;

  @override
  Future<List<AvisWithAuteur>> fetchForLieu(String idLieu, {int? limit}) {
    return Future.value([]);
  }

  @override
  Future<({double average, int count})> fetchStats(String idLieu) {
    return Future.value((average: 0.0, count: 0));
  }

  @override
  Future<Avis> save(Avis avis) async {
    saved.add(avis);
    return Avis(
      idAvis: 42,
      note: avis.note,
      commentaire: avis.commentaire,
      date: avis.date,
      idLieu: avis.idLieu,
      idUtilisateur: avis.idUtilisateur,
      isValidated: avis.isValidated,
      moderationStatus: avis.moderationStatus,
    );
  }

  @override
  Future<void> moderateReview(Avis avis) {
    moderatedAvis = avis;
    return moderationCompleter.future;
  }
}
