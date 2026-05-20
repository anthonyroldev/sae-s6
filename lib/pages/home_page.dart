import 'package:flutter/material.dart';

import '../components/app_bottom_nav_bar.dart';
import '../components/nav_bar_item.dart';
import 'feed_page.dart';
import 'map_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  static const _navItems = [
    NavBarItem(icon: Icons.home_outlined, activeIcon: Icons.home),
    NavBarItem(icon: Icons.map_outlined, activeIcon: Icons.map),
  ];

  static const _pages = [FeedPage(), MapPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onItemSelected: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
