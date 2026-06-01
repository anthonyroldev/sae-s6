import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/firestore_data_converter.dart';

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
    final normalized = FirestoreDataConverter.toStringValue(value)
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

/// Campus place ready for Firestore reads and writes.
class Lieu {
  final String id;
  final String nom;
  final String description;
  final GeoPoint adresse;
  final String horaireOuverture;
  final String imageUrl;
  final LieuCategorie categorie;

  /// Creates a campus place.
  const Lieu({
    this.id = '',
    required this.nom,
    required this.description,
    this.adresse = const GeoPoint(0, 0),
    this.categorie = LieuCategorie.services,
    String? horaireOuverture,
    String? heures,
    String? photo,
    String? imageUrl,
  }) : horaireOuverture = horaireOuverture ?? heures ?? '',
       imageUrl = imageUrl ?? photo ?? '';

  /// Creates a place from Firestore data.
  factory Lieu.fromMap(Map<String, dynamic> map) {
    return Lieu(
      id: FirestoreDataConverter.toStringValue(map['idLieu']),
      nom: FirestoreDataConverter.toStringValue(map['nom']),
      description: FirestoreDataConverter.toStringValue(map['description']),
      adresse: FirestoreDataConverter.toGeoPoint(
        map['adresse'],
        fallbackLatitude: FirestoreDataConverter.toDouble(map['latitude']),
        fallbackLongitude: FirestoreDataConverter.toDouble(map['longitude']),
      ),
      horaireOuverture: FirestoreDataConverter.toHoraire(
        map['horaire'] ??
            map['horaires'] ??
            map['horaireOuverture'] ??
            map['heures'] ??
            map['openingHours'],
      ),
      imageUrl: FirestoreDataConverter.toStringValue(
        map['photo'] ?? map['imageUrl'],
      ),
      categorie: LieuCategorie.fromValue(map['categorie']),
    );
  }

  /// Converts this place to Firestore data.
  Map<String, dynamic> toMap() {
    return {
      'idLieu': id,
      'nom': nom,
      'description': description,
      'adresse': adresse,
      'horaire': horaireOuverture,
      'imageUrl': imageUrl,
      'categorie': categorie.value,
    };
  }

  /// Creates a copy of this place with selected values replaced.
  Lieu copyWith({
    int? id,
    String? nom,
    String? description,
    GeoPoint? adresse,
    String? horaireOuverture,
    String? imageUrl,
    LieuCategorie? categorie,
  }) {
    return Lieu(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      adresse: adresse ?? this.adresse,
      horaireOuverture: horaireOuverture ?? this.horaireOuverture,
      imageUrl: imageUrl ?? this.imageUrl,
      categorie: categorie ?? this.categorie,
    );
  }

  /// Opening hours alias used by place cards.
  String get heures => horaireOuverture;

  /// Whether the place is currently open.
  bool get isOpen => FirestoreDataConverter.isOpenFromHoraire(
    currentTimestamp: DateTime.now(),
    heures: horaireOuverture,
  );
}
