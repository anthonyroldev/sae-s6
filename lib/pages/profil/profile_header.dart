import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Header showing the current user identity.
class ProfileHeader extends StatelessWidget {
  /// Creates the profile header.
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mon Profil',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Jules Baron',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          'jules.baron@uphf.fr',
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
