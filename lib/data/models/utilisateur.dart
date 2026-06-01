import '../../core/utils/firestore_data_converter.dart';

/// App user ready for Supabase reads and writes.
///
/// The primary key [id] is the Supabase Auth user id (`auth.uid()`), which
/// links the row to the authenticated user.
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

  /// Creates a user from a Supabase row.
  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: FirestoreDataConverter.toStringValue(map['id']),
      nom: FirestoreDataConverter.toStringValue(map['nom']),
      email: FirestoreDataConverter.toStringValue(map['email']),
      positionGps: FirestoreDataConverter.toStringValue(
        map['position_gps'] ?? map['positionGPS'] ?? map['positionGps'],
      ),
    );
  }

  /// Converts this user to a Supabase row.
  Map<String, dynamic> toMap() {
    return {'id': id, 'nom': nom, 'email': email, 'position_gps': positionGps};
  }
}
