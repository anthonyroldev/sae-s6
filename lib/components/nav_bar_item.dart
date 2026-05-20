import 'package:flutter/material.dart';

class NavBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String? label;

  const NavBarItem({required this.icon, required this.activeIcon, this.label});
}
