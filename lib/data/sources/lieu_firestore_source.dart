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
              if (data.containsKey('idLieu')) {
                return Lieu.fromMap(data);
              }

              final parsedId = int.tryParse(snapshot.id);
              if (parsedId == null) {
                throw FormatException(
                  'Missing idLieu and non-numeric document ID for lieu: ${snapshot.id}',
                );
              }

              return Lieu.fromMap({...data, 'idLieu': parsedId});
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
    return _places.doc(lieu.id.toString()).set(lieu);
  }
}
