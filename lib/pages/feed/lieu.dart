import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/utils/firestore_data_converter.dart';

/// Campus place ready for Firestore reads and writes.
class Lieu {
  final int id;
  final String nom;
  final String description;
  final GeoPoint adresse;
  final String horaireOuverture;
  final String imageUrl;
  final String categorie;

  /// Local fallback icon.
  final IconData icon;

  /// Creates a campus place.
  const Lieu({
    this.id = 0,
    required this.nom,
    required this.description,
    this.adresse = const GeoPoint(0, 0),
    required this.categorie,
    String? horaireOuverture,
    String? heures,
    String? photo,
    String? imageUrl,
    this.icon = Icons.place,
  }) : horaireOuverture = horaireOuverture ?? heures ?? '',
       imageUrl = imageUrl ?? photo ?? '';

  /// Creates a place from Firestore data.
  factory Lieu.fromMap(Map<String, dynamic> map) {
    return Lieu(
      id: FirestoreDataConverter.toInt(map['idLieu']),
      nom: FirestoreDataConverter.toStringValue(map['nom']),
      description: FirestoreDataConverter.toStringValue(map['description']),
      adresse: FirestoreDataConverter.toGeoPoint(
        map['adresse'],
        fallbackLatitude: FirestoreDataConverter.toDouble(map['latitude']),
        fallbackLongitude: FirestoreDataConverter.toDouble(map['longitude']),
      ),
      horaireOuverture: FirestoreDataConverter.toHoraire(
        map['horaire'] ?? map['horaireOuverture'] ?? map['heures'],
      ),
      imageUrl: FirestoreDataConverter.toStringValue(
        map['photo'] ?? map['imageUrl'],
      ),
      categorie: FirestoreDataConverter.toStringValue(map['categorie']),
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
      'categorie': categorie,
    };
  }

  String get heures => horaireOuverture;

  bool get isOpen => FirestoreDataConverter.isOpenFromHoraire(
    currentTimestamp: DateTime.now(),
    heures: horaireOuverture,
  );
}
