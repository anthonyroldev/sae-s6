import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants/app_colors.dart';

/// Campus map page.
class MapPage extends StatelessWidget {
  /// Creates the campus map page.
  const MapPage({super.key});

  static const LatLng _campusCenter = LatLng(50.3559, 3.5182);

  /// Builds the campus map page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: _campusCenter,
          initialZoom: 16,
          minZoom: 3,
          maxZoom: 19,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'le_repere',
          ),
        ],
      ),
    );
  }
}
