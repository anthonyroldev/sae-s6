import 'package:flutter/material.dart';

import 'bottom_nav_item.dart';
import 'nav_bar_item.dart';

class AppBottomNavBar extends StatelessWidget {
  static const double _contentHeight = 56;
  static const double _bottomGap = 12;
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final List<NavBarItem> items;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: _bottomGap),
        child: SizedBox(
          height: _contentHeight,
          child: Row(
            children: items.asMap().entries.map((entry) {
              return BottomNavItem(
                item: entry.value,
                isActive: entry.key == currentIndex,
                onTap: () => onItemSelected(entry.key),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
