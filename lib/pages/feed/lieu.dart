import 'package:flutter/material.dart';

import '../../core/utils/firestore_data_converter.dart';

/// Campus place ready for Firestore reads and writes.
class Lieu {
  final int idLieu;
  final String nom;
  final String description;
  final String adresse;
  final String horaireOuverture;
  final String photo;
  final String categorie;
  final double latitude;
  final double longitude;
  final bool etatOuverture;

  /// Local fallback icon.
  final IconData icon;

  /// Creates a campus place.
  const Lieu({
    this.idLieu = 0,
    required this.nom,
    required this.description,
    this.adresse = '',
    required this.categorie,
    String? horaireOuverture,
    String? heures,
    String? photo,
    String? imageUrl,
    this.latitude = 0,
    this.longitude = 0,
    bool? etatOuverture,
    bool? isOpen,
    this.icon = Icons.place,
  }) : horaireOuverture = horaireOuverture ?? heures ?? '',
       photo = photo ?? imageUrl ?? '',
       etatOuverture = etatOuverture ?? isOpen ?? false;

  /// Creates a place from Firestore data.
  factory Lieu.fromMap(Map<String, dynamic> map) {
    return Lieu(
      idLieu: FirestoreDataConverter.toInt(map['idLieu']),
      nom: FirestoreDataConverter.toStringValue(map['nom']),
      description: FirestoreDataConverter.toStringValue(map['description']),
      adresse: FirestoreDataConverter.toStringValue(map['adresse']),
      horaireOuverture: FirestoreDataConverter.toStringValue(
        map['horaireOuverture'] ?? map['heures'],
      ),
      photo: FirestoreDataConverter.toStringValue(
        map['photo'] ?? map['imageUrl'],
      ),
      categorie: FirestoreDataConverter.toStringValue(map['categorie']),
      latitude: FirestoreDataConverter.toDouble(map['latitude']),
      longitude: FirestoreDataConverter.toDouble(map['longitude']),
      etatOuverture: FirestoreDataConverter.toBool(
        map['etatOuverture'] ?? map['isOpen'],
      ),
    );
  }

  /// Converts this place to Firestore data.
  Map<String, dynamic> toMap() {
    return {
      'idLieu': idLieu,
      'nom': nom,
      'description': description,
      'adresse': adresse,
      'horaireOuverture': horaireOuverture,
      'photo': photo,
      'categorie': categorie,
      'latitude': latitude,
      'longitude': longitude,
      'etatOuverture': etatOuverture,
    };
  }

  String get heures => horaireOuverture;
  String get imageUrl => photo;
  bool get isOpen => etatOuverture;
}
