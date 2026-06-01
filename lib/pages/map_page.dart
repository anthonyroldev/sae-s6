import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'add_lieu_page.dart';

/// Map tab.
class MapPage extends StatelessWidget {
  /// Creates the map tab.
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const AddLieuPage()));
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        tooltip: 'Ajouter un lieu',
        child: const Icon(Icons.add),
      ),
      body: const Center(child: Text('Map')),
    );
  }
}
