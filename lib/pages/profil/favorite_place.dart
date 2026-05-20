import 'package:flutter/material.dart';

/// Mock favorite place shown on the profile page.
class FavoritePlace {
  /// Place name.
  final String name;

  /// Short place location.
  final String subtitle;

  /// Displayed category.
  final String category;

  /// Placeholder icon for the place visual.
  final IconData icon;

  /// Creates a favorite place.
  const FavoritePlace({
    required this.name,
    required this.subtitle,
    required this.category,
    required this.icon,
  });
}
