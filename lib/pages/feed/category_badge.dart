import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'lieu.dart';
import 'place_badge.dart';

/// Place category badge.
class CategoryBadge extends StatelessWidget {
  /// Place used for category data.
  final Lieu place;

  /// Creates a category badge.
  const CategoryBadge({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return PlaceBadge(
      label: place.categorie,
      color: AppColors.secondaryText,
      backgroundColor: AppColors.surfaceVariant,
      icon: place.icon,
    );
  }
}
