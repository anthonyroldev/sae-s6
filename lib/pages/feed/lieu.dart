import 'package:flutter/material.dart';

/// Représente un lieu avec ses informations
class Lieu {
  final String nom;
  final String description;
  final String categorie;
  final String heures;
  final IconData icon;
  final String imageUrl;
  final bool isOpen;
  final double latitude;
  final double longitude;
  final String? adresse;

  const Lieu({
    required this.nom,
    required this.description,
    required this.categorie,
    required this.heures,
    required this.icon,
    required this.imageUrl,
    required this.isOpen,
    required this.latitude,
    required this.longitude,
    this.adresse,
  });
}
