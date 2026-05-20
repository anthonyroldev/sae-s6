import 'package:cloud_firestore/cloud_firestore.dart';

import 'lieu.dart';

/// Firestore source for campus places.
class LieuFirestoreSource {
  static const _collectionPath = 'places';
  final CollectionReference<Lieu> _places;

  LieuFirestoreSource({FirebaseFirestore? firestore})
    : _places = (firestore ?? FirebaseFirestore.instance)
          .collection(_collectionPath)
          .withConverter<Lieu>(
            fromFirestore: (snapshot, _) {
              final data = snapshot.data() ?? <String, dynamic>{};
              return Lieu.fromMap({
                ...data,
                if (!data.containsKey('idLieu'))
                  'idLieu': int.tryParse(snapshot.id) ?? 0,
              });
            },
            toFirestore: (lieu, _) => lieu.toMap(),
          );

  /// Watches all campus places.
  Stream<List<Lieu>> watchAll() {
    return _places
        .orderBy('nom')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Creates or updates a campus place.
  Future<void> save(Lieu lieu) {
    return _places.doc(lieu.idLieu.toString()).set(lieu);
  }
}
