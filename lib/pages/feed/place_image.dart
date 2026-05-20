import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'category_badge.dart';
import 'lieu.dart';
import 'status_badge.dart';

/// Place image with category and status overlays.
class PlaceImage extends StatelessWidget {
  /// Place to display.
  final Lieu place;

  /// Creates a place image.
  const PlaceImage({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            place.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => ColoredBox(
              color: AppColors.surfaceVariant,
              child: Icon(place.icon, color: AppColors.secondaryText, size: 48),
            ),
          ),
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: StatusBadge(isOpen: place.isOpen),
          ),
          Positioned(
            left: AppSpacing.sm,
            bottom: AppSpacing.sm,
            child: CategoryBadge(place: place),
          ),
        ],
      ),
    );
  }
}
