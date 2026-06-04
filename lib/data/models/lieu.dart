import '../../core/utils/supabase_data_converter.dart';

/// Place category used by Supabase and feed filters.
enum LieuCategorie {
  all('Pour vous', ''),
  repas('Repas', 'repas'),
  bibliotheque('Bibliotheque', 'bibliotheque'),
  associations('Assos', 'associations'),
  services('Services', 'services'),
  proximite('A proximite', 'proximite');

  /// Display label.
  final String label;

  /// Supabase value.
  final String value;

  const LieuCategorie(this.label, this.value);

  /// Builds a category from Supabase data.
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
  final Duration? heureOuverture;
  final Duration? heureFermeture;
  final String imageUrl;
  final LieuCategorie categorie;
  final bool isValidated;
  final bool isPermanent;
  final DateTime? dateFinPrestation;

  /// Creates a campus place.
  const Lieu({
    this.id = '',
    required this.nom,
    required this.description,
    this.latitude = 0,
    this.longitude = 0,
    this.categorie = LieuCategorie.services,
    this.isValidated = true,
    this.isPermanent = true,
    this.dateFinPrestation,
    this.heureOuverture,
    this.heureFermeture,
    String? photo,
    String? imageUrl,
  }) : imageUrl = imageUrl ?? photo ?? '';

  /// Creates a place from a Supabase row.
  factory Lieu.fromMap(Map<String, dynamic> map) {
    return Lieu(
      id: SupabaseDataConverter.toStringValue(map['id'] ?? map['idLieu']),
      nom: SupabaseDataConverter.toStringValue(map['nom']),
      description: SupabaseDataConverter.toStringValue(map['description']),
      latitude: SupabaseDataConverter.toDouble(map['latitude'] ?? map['lat']),
      longitude: SupabaseDataConverter.toDouble(map['longitude'] ?? map['lng']),
      heureOuverture: SupabaseDataConverter.toTimeOfDay(map['heure_ouverture']),
      heureFermeture: SupabaseDataConverter.toTimeOfDay(map['heure_fermeture']),
      imageUrl: SupabaseDataConverter.toStringValue(
        map['image_url'] ?? map['photo'] ?? map['imageUrl'],
      ),
      categorie: LieuCategorie.fromValue(map['categorie']),
      isValidated: map.containsKey('is_validated')
          ? SupabaseDataConverter.toBool(map['is_validated'])
          : map.containsKey('isValidated')
          ? SupabaseDataConverter.toBool(map['isValidated'])
          : true,
      isPermanent: (map['is_permanent'] as bool?) ?? true,
      dateFinPrestation: map['date_fin_prestation'] != null
          ? DateTime.parse(map['date_fin_prestation'].toString())
          : null,
    );
  }

  /// Converts this place to a Supabase row.
  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'nom': nom,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'heure_ouverture': SupabaseDataConverter.formatTimeOfDay(heureOuverture),
      'heure_fermeture': SupabaseDataConverter.formatTimeOfDay(heureFermeture),
      'image_url': imageUrl,
      'categorie': categorie.value,
      'is_validated': isValidated,
      'is_permanent': isPermanent,
      if (!isPermanent && dateFinPrestation != null)
        'date_fin_prestation':
            '${dateFinPrestation!.year.toString().padLeft(4, '0')}-'
            '${dateFinPrestation!.month.toString().padLeft(2, '0')}-'
            '${dateFinPrestation!.day.toString().padLeft(2, '0')}',
    };
  }

  /// Creates a copy of this place with selected values replaced.
  Lieu copyWith({
    String? id,
    String? nom,
    String? description,
    double? latitude,
    double? longitude,
    Duration? heureOuverture,
    Duration? heureFermeture,
    String? imageUrl,
    LieuCategorie? categorie,
    bool? isValidated,
    bool? isPermanent,
    DateTime? dateFinPrestation,
  }) {
    return Lieu(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heureOuverture: heureOuverture ?? this.heureOuverture,
      heureFermeture: heureFermeture ?? this.heureFermeture,
      imageUrl: imageUrl ?? this.imageUrl,
      categorie: categorie ?? this.categorie,
      isValidated: isValidated ?? this.isValidated,
      isPermanent: isPermanent ?? this.isPermanent,
      dateFinPrestation: dateFinPrestation ?? this.dateFinPrestation,
    );
  }

  /// Opening hours label used by place cards.
  String get heures {
    final ouverture = SupabaseDataConverter.formatTimeOfDay(heureOuverture);
    final fermeture = SupabaseDataConverter.formatTimeOfDay(heureFermeture);
    if (ouverture == null || fermeture == null) {
      return '';
    }
    if (ouverture == fermeture) {
      return '24h/24';
    }
    return '$ouverture - $fermeture';
  }

  /// Whether the place is currently open.
  bool get isOpen => SupabaseDataConverter.isOpenAt(
    currentTimestamp: DateTime.now(),
    heureOuverture: heureOuverture,
    heureFermeture: heureFermeture,
  );
}
