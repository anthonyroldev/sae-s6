import '../../core/utils/firestore_data_converter.dart';

/// App user ready for Firestore reads and writes.
class Utilisateur {
  final String id;
  final String nom;
  final String email;
  final String positionGps;

  /// Creates an app user.
  const Utilisateur({
    required this.id,
    required this.nom,
    required this.email,
    required this.positionGps,
  });

  /// Creates a user from Firestore data.
  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: FirestoreDataConverter.toStringValue(map['id']),
      nom: FirestoreDataConverter.toStringValue(map['nom']),
      email: FirestoreDataConverter.toStringValue(map['email']),
      positionGps: FirestoreDataConverter.toStringValue(
        map['positionGPS'] ?? map['positionGps'],
      ),
    );
  }

  /// Converts this user to Firestore data.
  Map<String, dynamic> toMap() {
    return {'id': id, 'nom': nom, 'email': email, 'positionGPS': positionGps};
  }
}
