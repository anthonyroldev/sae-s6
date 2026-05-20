import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'place_badge.dart';

/// Open or closed status badge.
class StatusBadge extends StatelessWidget {
  /// Whether place is open.
  final bool isOpen;

  /// Creates a status badge.
  const StatusBadge({super.key, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return PlaceBadge(
      label: isOpen ? 'Ouvert' : 'Fermé',
      color: isOpen ? AppColors.successText : AppColors.errorText,
      backgroundColor: isOpen
          ? AppColors.successBackground
          : AppColors.errorBackground,
    );
  }
}
