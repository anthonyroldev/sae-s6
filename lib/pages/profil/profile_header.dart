import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Header showing the current user identity.
class ProfileHeader extends StatelessWidget {
  /// User display name.
  final String name;

  /// User email address.
  final String email;

  /// Optional user GPS position.
  final String positionGps;

  /// Creates the profile header.
  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.positionGps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mon Profil',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          name,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          email,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        if (positionGps.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            positionGps,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}
