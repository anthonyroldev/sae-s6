import '../../core/utils/supabase_data_converter.dart';

/// Place category used by Firestore and feed filters.
enum LieuCategorie {
  all('Pour vous', ''),
  repas('Repas', 'repas'),
  bibliotheque('Bibliotheque', 'bibliotheque'),
  associations('Assos', 'associations'),
  services('Services', 'services'),
  proximite('A proximite', 'proximite');

  /// Display label.
  final String label;

  /// Firestore value.
  final String value;

  const LieuCategorie(this.label, this.value);

  /// Builds a category from Firestore data.
  static LieuCategorie fromValue(Object? value) {
    final normalized = SupabaseDataConverter.toStringValue(value)
        .trim()
        .toLowerCase()
        .replaceAll(String.fromCharCode(0x00e9), 'e')
        .replaceAll(String.fromCharCode(0x00e8), 'e')
        .replaceAll(String.fromCharCode(0x00ea), 'e')
        .replaceAll(String.fromCharCode(0x00e0), 'a');
    if (normalized.contains('repas') ||
        normalized.contains('restauration') ||
        normalized.contains('cafe')) {
      return LieuCategorie.repas;
    }
    if (normalized.contains('bibli')) {
      return LieuCategorie.bibliotheque;
    }
    if (normalized.contains('asso')) {
      return LieuCategorie.associations;
    }
    if (normalized.contains('proximite')) {
      return LieuCategorie.proximite;
    }
    if (normalized.contains('service')) {
      return LieuCategorie.services;
    }
    return LieuCategorie.values.firstWhere(
      (category) =>
          category.value == normalized ||
          category.label.toLowerCase() == normalized,
      orElse: () => LieuCategorie.services,
    );
  }
}

/// Campus place ready for Supabase reads and writes.
class Lieu {
  final String id;
  final String nom;
  final String description;
  final double latitude;
  final double longitude;
  final String horaireOuverture;
  final String imageUrl;
  final LieuCategorie categorie;

  /// Creates a campus place.
  const Lieu({
    this.id = '',
    required this.nom,
    required this.description,
    this.latitude = 0,
    this.longitude = 0,
    this.categorie = LieuCategorie.services,
    String? horaireOuverture,
    String? heures,
    String? photo,
    String? imageUrl,
  }) : horaireOuverture = horaireOuverture ?? heures ?? '',
       imageUrl = imageUrl ?? photo ?? '';

  /// Creates a place from a Supabase row.
  factory Lieu.fromMap(Map<String, dynamic> map) {
    return Lieu(
      id: SupabaseDataConverter.toStringValue(map['id'] ?? map['idLieu']),
      nom: SupabaseDataConverter.toStringValue(map['nom']),
      description: SupabaseDataConverter.toStringValue(map['description']),
      latitude: SupabaseDataConverter.toDouble(map['latitude'] ?? map['lat']),
      longitude: SupabaseDataConverter.toDouble(map['longitude'] ?? map['lng']),
      horaireOuverture: SupabaseDataConverter.toHoraire(
        map['horaire'] ??
            map['horaires'] ??
            map['horaireOuverture'] ??
            map['heures'] ??
            map['openingHours'],
      ),
      imageUrl: SupabaseDataConverter.toStringValue(
        map['image_url'] ?? map['photo'] ?? map['imageUrl'],
      ),
      categorie: LieuCategorie.fromValue(map['categorie']),
    );
  }

  /// Converts this place to a Supabase row.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'horaire': horaireOuverture,
      'image_url': imageUrl,
      'categorie': categorie.value,
    };
  }

  /// Creates a copy of this place with selected values replaced.
  Lieu copyWith({
    String? id,
    String? nom,
    String? description,
    double? latitude,
    double? longitude,
    String? horaireOuverture,
    String? imageUrl,
    LieuCategorie? categorie,
  }) {
    return Lieu(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      horaireOuverture: horaireOuverture ?? this.horaireOuverture,
      imageUrl: imageUrl ?? this.imageUrl,
      categorie: categorie ?? this.categorie,
    );
  }

  /// Opening hours alias used by place cards.
  String get heures => horaireOuverture;

  /// Whether the place is currently open.
  bool get isOpen => SupabaseDataConverter.isOpenFromHoraire(
    currentTimestamp: DateTime.now(),
    heures: horaireOuverture,
  );
}
