import 'package:flutter/material.dart';

import '../components/app_bottom_nav_bar.dart';
import '../components/nav_bar_item.dart';
import 'feed_page.dart';
import 'map_page.dart';
import 'profil_page.dart';

/// Main page hosting the bottom navigation destinations.
class HomePage extends StatefulWidget {
  /// Creates the home page.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  static const _navItems = [
    NavBarItem(icon: Icons.home_outlined, activeIcon: Icons.home),
    NavBarItem(icon: Icons.map_outlined, activeIcon: Icons.map),
    NavBarItem(icon: Icons.person_outline, activeIcon: Icons.person),
  ];

  static final _pages = <Widget>[const FeedPage(), const MapPage(), ProfilPage()];

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
