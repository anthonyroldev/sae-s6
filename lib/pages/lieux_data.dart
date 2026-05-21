import 'package:flutter/material.dart';

import 'feed/lieu.dart';

// Local place data shared by feed and map pages.
class LieuxData {
  /// Shared list of campus places.
  static const List<Lieu> places = [
    Lieu(
      nom: 'Cafétéria INSA',
      description: 'Le restaurant universitaire du campus',
      categorie: 'Repas',
      heures: '11h30 - 14h00',
      icon: Icons.restaurant,
      imageUrl: '',
      isOpen: true,
      latitude: 0,
      longitude: 0,
    ),
    Lieu(
      nom: 'BU Sciences',
      description: 'Bibliothèque universitaire, accès WiFi',
      categorie: 'Bibliothèque',
      heures: '8h00 - 20h00',
      icon: Icons.menu_book,
      imageUrl: '',
      isOpen: true,
      latitude: 0,
      longitude: 0,
    ),
    Lieu(
      nom: 'BDE INSA',
      description: 'Bureau des étudiants, salle des assos',
      categorie: 'Associations',
      heures: '14h00 - 18h00',
      icon: Icons.groups,
      imageUrl: '',
      isOpen: false,
      latitude: 0,
      longitude: 0,
    ),
    Lieu(
      nom: 'Le Kfet',
      description: 'Petite restauration rapide, snacks, café',
      categorie: 'Restauration',
      heures: '8h00 - 16h00',
      icon: Icons.local_cafe,
      imageUrl: '',
      isOpen: true,
      latitude: 0,
      longitude: 0,
    ),
  ];

  /// Prevents instantiation.
  const LieuxData._();
}
