import '../../core/utils/firestore_data_converter.dart';

/// Campus association ready for Firestore reads and writes.
class Association {
  final int idAssociation;
  final String nom;
  final String description;
  final String contact;

  const Association({
    required this.idAssociation,
    required this.nom,
    required this.description,
    required this.contact,
  });

  /// Creates an association from Firestore data.
  factory Association.fromMap(Map<String, dynamic> map) {
    return Association(
      idAssociation: FirestoreDataConverter.toInt(map['idAssociation']),
      nom: FirestoreDataConverter.toStringValue(map['nom']),
      description: FirestoreDataConverter.toStringValue(map['description']),
      contact: FirestoreDataConverter.toStringValue(map['contact']),
    );
  }

  /// Converts this association to Firestore data.
  Map<String, dynamic> toMap() {
    return {
      'idAssociation': idAssociation,
      'nom': nom,
      'description': description,
      'contact': contact,
    };
  }
}
