import 'package:flutter/material.dart';

import '../components/app_bottom_nav_bar.dart';
import '../components/nav_bar_item.dart';
import '../data/models/user_role.dart';
import '../data/sources/role_source.dart';
import '../data/sources/role_supabase_source.dart';
import 'admin/moderation_propositions_page.dart';
import 'feed_page.dart';
import 'map_page.dart';
import 'profil_page.dart';

/// Main page hosting the bottom navigation destinations.
class HomePage extends StatefulWidget {
  /// Role backend, used to show administrator destinations.
  final RoleSource? roleSource;

  /// Creates the home page.
  const HomePage({super.key, this.roleSource});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final RoleSource _roleSource = widget.roleSource ?? RoleSupabaseSource();
  int _currentIndex = 0;

  static const _baseNavItems = [
    NavBarItem(icon: Icons.home_outlined, activeIcon: Icons.home),
    NavBarItem(icon: Icons.map_outlined, activeIcon: Icons.map),
    NavBarItem(icon: Icons.person_outline, activeIcon: Icons.person),
  ];

  static const _adminNavItem = NavBarItem(
    icon: Icons.fact_check_outlined,
    activeIcon: Icons.fact_check,
  );

  List<Widget> _pages(bool isAdmin) => [
    const FeedPage(),
    const MapPage(),
    ProfilPage(),
    if (isAdmin) ModerationPropositionsPage(roleSource: _roleSource),
  ];

  List<NavBarItem> _navItems(bool isAdmin) => [
    ..._baseNavItems,
    if (isAdmin) _adminNavItem,
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserRole>(
      initialData: _roleSource.currentRole,
      stream: _roleSource.roleChanges,
      builder: (context, snapshot) {
        final isAdmin = (snapshot.data ?? UserRole.utilisateur).isAdmin;
        final pages = _pages(isAdmin);
        final navItems = _navItems(isAdmin);
        if (_currentIndex >= pages.length) {
          _currentIndex = pages.length - 1;
        }

        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: pages),
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: _currentIndex,
            items: navItems,
            onItemSelected: (index) => setState(() => _currentIndex = index),
          ),
        );
      },
    );
  }
}
