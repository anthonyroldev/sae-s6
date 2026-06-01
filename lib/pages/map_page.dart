import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants/app_colors.dart';
import '../data/models/lieu.dart';
import '../data/sources/lieu_firestore_source.dart';

/// Campus map page.
class MapPage extends StatefulWidget {
  /// Creates the campus map page.
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _campusCenter = LatLng(50.3559, 3.5182);
  final _lieuSource = LieuFirestoreSource();
  late final Stream<List<Lieu>> _lieuxStream;

  @override
  void initState() {
    super.initState();
    _lieuxStream = _lieuSource.watchAll();
  }

  /// Builds the campus map page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<Lieu>>(
        stream: _lieuxStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Map Firestore error: ${snapshot.error}');
          }

          final places = snapshot.hasData ? snapshot.data! : const <Lieu>[];
          final markers = places
              .where(_hasValidCoordinates)
              .map(_buildMarker)
              .toList(growable: false);

          return Stack(
            fit: StackFit.expand,
            children: [
              _CampusMap(markers: markers),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator()),
              if (snapshot.hasError)
                const Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Erreur de chargement des lieux',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  bool _hasValidCoordinates(Lieu place) {
    return place.adresse.latitude != 0 || place.adresse.longitude != 0;
  }

  Marker _buildMarker(Lieu place) {
    return Marker(
      point: LatLng(place.adresse.latitude, place.adresse.longitude),
      width: 96,
      height: 64,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_pin, color: Colors.red, size: 40),
          Text(
            place.nom,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CampusMap extends StatelessWidget {
  final List<Marker> markers;

  const _CampusMap({required this.markers});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: _MapPageState._campusCenter,
        initialZoom: 16,
        minZoom: 3,
        maxZoom: 19,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'le_repere',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
