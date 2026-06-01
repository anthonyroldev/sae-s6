import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/lieu.dart';

/// Firestore source for campus places.
class LieuFirestoreSource {
  static const _collectionPath = 'lieux';
  final CollectionReference<Lieu> _places;

  LieuFirestoreSource({FirebaseFirestore? firestore})
    : _places = (firestore ?? FirebaseFirestore.instance)
          .collection(_collectionPath)
          .withConverter<Lieu>(
            fromFirestore: (snapshot, _) {
              final data = snapshot.data() ?? <String, dynamic>{};
              return Lieu.fromMap({
                ...data,
                if (!data.containsKey('idLieu')) 'idLieu': snapshot.id,
              });
            },
            toFirestore: (lieu, _) => lieu.toMap(),
          );

  /// Watches all campus places.
  Stream<List<Lieu>> watchAll() {
    return _places.snapshots().map((snapshot) {
      final places = snapshot.docs.map((doc) => doc.data()).toList();
      places.sort((first, second) => first.nom.compareTo(second.nom));
      return places;
    });
  }

  /// Creates or updates a campus place.
  Future<void> save(Lieu lieu) {
    return _places.doc(lieu.id).set(lieu);
  }

  /// Creates a new campus place with the next available numeric identifier.
  Future<void> create(Lieu lieu) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final placeToCreate = lieu.copyWith(id: id);
    return _places.doc(id).set(placeToCreate);
  }
}
