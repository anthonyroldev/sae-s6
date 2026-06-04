import 'package:flutter/material.dart';

import '../../data/models/lieu.dart';

/// Returns a presentation icon for a place category.
IconData iconForCategory(LieuCategorie category) {
  switch (category) {
    case LieuCategorie.repas:
      return Icons.restaurant;
    case LieuCategorie.bibliotheque:
      return Icons.menu_book;
    case LieuCategorie.associations:
      return Icons.groups;
    case LieuCategorie.services:
      return Icons.info_outline;
    case LieuCategorie.proximite:
    case LieuCategorie.all:
      return Icons.place;
  }
}
