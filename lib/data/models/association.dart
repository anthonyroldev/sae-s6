import '../../core/utils/supabase_data_converter.dart';

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
      idAssociation: SupabaseDataConverter.toInt(map['idAssociation']),
      nom: SupabaseDataConverter.toStringValue(map['nom']),
      description: SupabaseDataConverter.toStringValue(map['description']),
      contact: SupabaseDataConverter.toStringValue(map['contact']),
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
