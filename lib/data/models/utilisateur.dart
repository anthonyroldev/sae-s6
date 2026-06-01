import '../../core/utils/supabase_data_converter.dart';

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
      id: SupabaseDataConverter.toStringValue(map['id']),
      nom: SupabaseDataConverter.toStringValue(map['nom']),
      email: SupabaseDataConverter.toStringValue(map['email']),
      positionGps: SupabaseDataConverter.toStringValue(
        map['position_gps'] ?? map['positionGPS'] ?? map['positionGps'],
      ),
    );
  }

  /// Converts this user to a Supabase row.
  Map<String, dynamic> toMap() {
    return {'id': id, 'nom': nom, 'email': email, 'position_gps': positionGps};
  }
}
