import '../../core/utils/supabase_data_converter.dart';
import 'utilisateur.dart';

/// Administrator user.
class Administrateur extends Utilisateur {
  /// Creates an administrator.
  const Administrateur({
    required super.id,
    required super.nom,
    required super.email,
    required super.positionGps,
  });

  /// Creates an administrator from Firestore data.
  factory Administrateur.fromMap(Map<String, dynamic> map) {
    return Administrateur(
      id: SupabaseDataConverter.toStringValue(map['id']),
      nom: SupabaseDataConverter.toStringValue(map['nom']),
      email: SupabaseDataConverter.toStringValue(map['email']),
      positionGps: SupabaseDataConverter.toStringValue(
        map['positionGPS'] ?? map['positionGps'],
      ),
    );
  }
}
