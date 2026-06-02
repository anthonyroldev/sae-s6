import '../../core/utils/supabase_data_converter.dart';
import 'user_role.dart';

/// App user ready for Supabase reads and writes.
///
/// The primary key [id] is the Supabase Auth user id (`auth.uid()`), which
/// links the row to the authenticated user.
class Utilisateur {
  final String id;
  final String nom;
  final String email;
  final String positionGps;

  /// Application role. Server-managed: read from the row but never written by
  /// the client (see [toMap]).
  final UserRole role;

  /// Creates an app user.
  const Utilisateur({
    required this.id,
    required this.nom,
    required this.email,
    required this.positionGps,
    this.role = UserRole.utilisateur,
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
      role: UserRole.fromValue(map['role']),
    );
  }

  /// Converts this user to a Supabase row.
  ///
  /// `role` is intentionally omitted: it is managed server-side and the client
  /// has no write privilege on that column. Use the `set_user_role` RPC (admins
  /// only) to change a role.
  Map<String, dynamic> toMap() {
    return {'id': id, 'nom': nom, 'email': email, 'position_gps': positionGps};
  }
}
