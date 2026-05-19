import 'package:flutter/material.dart';

import 'nav_bar_item.dart';

class BottomNavItem extends StatelessWidget {
  final NavBarItem item;
  final bool isActive;
  final VoidCallback onTap;

  const BottomNavItem({
    super.key,
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? Theme.of(context).colorScheme.onSurface
        : Theme.of(context).colorScheme.secondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedScale(
          scale: isActive ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                color: color,
                size: 24,
              ),
              if (item.label != null) ...[
                const SizedBox(height: 4),
                Text(
                  item.label!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                    letterSpacing: 0.05,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
