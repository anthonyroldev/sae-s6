import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'place_badge.dart';

/// Badge indiquant si un lieu est permanent ou temporaire.
class PermanenceBadge extends StatelessWidget {
  final bool isPermanent;

  const PermanenceBadge({super.key, required this.isPermanent});

  @override
  Widget build(BuildContext context) {
    return PlaceBadge(
      label: isPermanent ? 'Permanent' : 'Temporaire',
      color: isPermanent ? AppColors.successText : AppColors.warningText,
      backgroundColor: isPermanent
          ? AppColors.successBackground
          : AppColors.warningBackground,
      icon: isPermanent ? Icons.push_pin_outlined : Icons.schedule_outlined,
    );
  }
}
