import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'settings_tile.dart';

/// Settings actions displayed on the profile page.
class SettingsCard extends StatelessWidget {
  /// Creates the settings card.
  const SettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            SettingsTile(
              title: 'Modifier le profil',
              icon: Icons.chevron_right,
              onPressed: () {},
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),
            SettingsTile(
              title: 'Notifications',
              icon: Icons.chevron_right,
              onPressed: () {},
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),
            SettingsTile(
              title: 'Déconnexion',
              textColor: AppColors.errorText,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
