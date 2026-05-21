import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants/app_colors.dart';
import 'lieux_data.dart';

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
          MarkerLayer(
            markers: LieuxData.places
                .map(
                  (place) => Marker(
                    point: LatLng(place.latitude, place.longitude),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}
