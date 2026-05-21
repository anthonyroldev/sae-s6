import '../../core/utils/firestore_data_converter.dart';
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
      id: FirestoreDataConverter.toStringValue(map['id']),
      nom: FirestoreDataConverter.toStringValue(map['nom']),
      email: FirestoreDataConverter.toStringValue(map['email']),
      positionGps: FirestoreDataConverter.toStringValue(
        map['positionGPS'] ?? map['positionGps'],
      ),
    );
  }
}
