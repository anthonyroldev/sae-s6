import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/models/lieu.dart';
import 'place_image.dart';

/// Card displaying one campus place.
class PlaceCard extends StatelessWidget {
  /// Place displayed by this card.
  final Lieu place;

  /// Whether the place is marked as favorite by the current user.
  final bool isFavorite;

  /// Mean rating from accepted reviews.
  final double ratingAverage;

  /// Number of accepted reviews.
  final int ratingCount;

  /// Called when the favorite button is pressed.
  final VoidCallback? onFavoritePressed;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Creates a place card.
  const PlaceCard({
    super.key,
    required this.place,
    this.isFavorite = false,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.onFavoritePressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlaceImage(place: place),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              place.nom,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ),
                          if (onFavoritePressed != null)
                            IconButton(
                              onPressed: onFavoritePressed,
                              tooltip: isFavorite
                                  ? 'Retirer des favoris'
                                  : 'Ajouter aux favoris',
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite
                                    ? AppColors.errorText
                                    : AppColors.secondaryText,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        place.description,
                        style: const TextStyle(
                          color: Color(0xFF45464D),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            ratingCount == 0 ? Icons.star_border : Icons.star,
                            color: ratingCount == 0
                                ? AppColors.secondaryText
                                : AppColors.accent,
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            ratingCount == 0
                                ? 'Aucun avis'
                                : '${ratingAverage.toStringAsFixed(1)} ($ratingCount)',
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          const Icon(
                            Icons.schedule,
                            color: AppColors.secondaryText,
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              place.heures.isEmpty
                                  ? 'Horaires non renseignés'
                                  : place.heures,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
