import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Mock filter chip.
class PlaceFilterChip extends StatelessWidget {
  /// Filter label.
  final String label;

  /// Whether this filter is selected.
  final bool isSelected;

  /// Called when this filter is selected.
  final VoidCallback onSelected;

  /// Creates a place filter chip.
  const PlaceFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selected : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.accent : AppColors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }
}
