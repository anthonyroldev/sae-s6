import 'package:flutter/material.dart';

import 'nav_bar_item.dart';

class BottomNavItem extends StatelessWidget {
  static const double _iconSize = 24;
  static const double _tapTargetSize = 48;
  static const double _indicatorWidth = 64;
  static const double _indicatorHeight = 40;

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
    final colorScheme = Theme.of(context).colorScheme;
    final color = isActive ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isActive,
        label: item.label,
        child: Center(
          child: SizedBox(
            height: _tapTargetSize,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(_indicatorHeight / 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: _indicatorWidth,
                height: _indicatorHeight,
                decoration: BoxDecoration(
                  color: isActive
                      ? colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(_indicatorHeight / 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isActive ? item.activeIcon : item.icon,
                      color: color,
                      size: _iconSize,
                    ),
                    if (item.label != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.label!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
