import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/lieu.dart';
import 'place_badge.dart';
import 'place_category_icon.dart';

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
      icon: iconForCategory(place.categorie),
    );
  }
}
