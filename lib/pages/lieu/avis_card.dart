import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/models/avis_with_auteur.dart';

/// Review card — name + stars + comment, matching Figma design.
class AvisCard extends StatelessWidget {
  final AvisWithAuteur item;

  const AvisCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  item.nomAuteur,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!item.avis.isValidated) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _ModerationBadge(status: item.avis.moderationStatus),
                ],
                const Spacer(),
                Text(
                  _formatDate(item.avis.date),
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < item.avis.note ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.avis.commentaire,
              style: const TextStyle(
                color: Color(0xFF45464D),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _ModerationBadge extends StatelessWidget {
  final String status;

  const _ModerationBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isDenied = status == 'denied';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDenied ? AppColors.errorBackground : AppColors.selected,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          isDenied ? 'Refusé' : 'En attente',
          style: TextStyle(
            color: isDenied ? AppColors.errorText : AppColors.accent,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
