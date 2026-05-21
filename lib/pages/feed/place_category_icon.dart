import 'package:flutter/material.dart';

/// Returns a presentation icon for a place category.
IconData iconForCategory(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('repas') ||
      normalized.contains('restauration') ||
      normalized.contains('cafe')) {
    return Icons.restaurant;
  }
  if (normalized.contains('bibli')) {
    return Icons.menu_book;
  }
  if (normalized.contains('asso')) {
    return Icons.groups;
  }
  if (normalized.contains('service')) {
    return Icons.info_outline;
  }
  return Icons.place;
}
