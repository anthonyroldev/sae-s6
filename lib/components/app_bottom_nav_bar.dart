import 'package:flutter/material.dart';

import 'bottom_nav_item.dart';
import 'nav_bar_item.dart';

class AppBottomNavBar extends StatelessWidget {
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
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: items.asMap().entries.map((entry) {
          return BottomNavItem(
            item: entry.value,
            isActive: entry.key == currentIndex,
            onTap: () => onItemSelected(entry.key),
          );
        }).toList(),
      ),
    );
  }
}
