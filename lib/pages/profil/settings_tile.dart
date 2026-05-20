import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Interactive row used in the profile settings card.
class SettingsTile extends StatelessWidget {
  /// Tile title.
  final String title;

  /// Optional trailing icon.
  final IconData? icon;

  /// Title color.
  final Color textColor;

  /// Action called when the tile is tapped.
  final VoidCallback onPressed;

  /// Creates a settings tile.
  const SettingsTile({
    super.key,
    required this.title,
    required this.onPressed,
    this.icon,
    this.textColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              if (icon != null)
                Icon(icon, color: AppColors.secondaryText, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
