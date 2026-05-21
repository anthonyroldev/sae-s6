import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/avis.dart';

/// Firestore source for place reviews.
class AvisFirestoreSource {
  static const _lieuxCollectionPath = 'lieux';
  static const _avisCollectionPath = 'avis';

  final FirebaseFirestore _firestore;

  /// Creates a Firestore source for place reviews.
  AvisFirestoreSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Watches reviews for a place.
  Stream<List<Avis>> watchForLieu(int idLieu) {
    return _collectionForLieu(idLieu).snapshots().map((snapshot) {
      final avis = snapshot.docs.map((doc) => doc.data()).toList();
      avis.sort((first, second) => second.date.compareTo(first.date));
      return avis;
    });
  }

  /// Adds or updates one review for a place.
  Future<void> save(Avis avis) {
    _validateAvis(avis);
    final id = avis.idAvis == 0
        ? DateTime.now().millisecondsSinceEpoch
        : avis.idAvis;
    return _collectionForLieu(avis.idLieu)
        .doc(id.toString())
        .set(
          Avis(
            idAvis: id,
            note: avis.note,
            commentaire: avis.commentaire,
            date: avis.date,
            idLieu: avis.idLieu,
            idUtilisateur: avis.idUtilisateur,
          ),
        );
  }

  CollectionReference<Avis> _collectionForLieu(int idLieu) {
    return _firestore
        .collection(_lieuxCollectionPath)
        .doc(idLieu.toString())
        .collection(_avisCollectionPath)
        .withConverter<Avis>(
          fromFirestore: (snapshot, _) {
            final data = snapshot.data() ?? <String, dynamic>{};
            return Avis.fromMap({
              ...data,
              if (!data.containsKey('idAvis'))
                'idAvis': int.tryParse(snapshot.id) ?? 0,
              if (!data.containsKey('idLieu')) 'idLieu': idLieu,
            });
          },
          toFirestore: (avis, _) => avis.toMap(),
        );
  }

  void _validateAvis(Avis avis) {
    if (avis.idLieu <= 0) {
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
