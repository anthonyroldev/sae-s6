import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/utilisateur.dart';

/// Firestore source for app users.
class UtilisateurFirestoreSource {
  static const _collectionPath = 'users';

  final CollectionReference<Utilisateur> _users;

  /// Creates a Firestore source for app users.
  UtilisateurFirestoreSource({FirebaseFirestore? firestore})
    : _users = (firestore ?? FirebaseFirestore.instance)
          .collection(_collectionPath)
          .withConverter<Utilisateur>(
            fromFirestore: (snapshot, _) {
              final data = snapshot.data() ?? <String, dynamic>{};
              return Utilisateur.fromMap({
                ...data,
                if (!data.containsKey('id')) 'id': snapshot.id,
              });
            },
            toFirestore: (utilisateur, _) => utilisateur.toMap(),
          );

  /// Watches one user by identifier.
  Stream<Utilisateur?> watchById(String id) {
    return _users.doc(id).snapshots().map((snapshot) => snapshot.data());
  }

  /// Fetches one user by identifier.
  Future<Utilisateur?> getById(String id) async {
    final snapshot = await _users.doc(id).get();
    return snapshot.data();
  }

  /// Creates or updates a user.
  Future<void> save(Utilisateur utilisateur) {
    return _users.doc(utilisateur.id).set(utilisateur);
  }
}
