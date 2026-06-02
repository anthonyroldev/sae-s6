import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:le_repere/data/sources/lieu_supabase_source.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/logger.dart';
import '../data/models/lieu.dart';
import 'add_lieu_page.dart';

/// Campus map page.
class MapPage extends StatefulWidget {
  /// Creates the campus map page.
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _campusCenter = LatLng(50.3559, 3.5182);
  final _lieuSource = LieuSupabaseSource();
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
            logger.e(
              'Failed to load map places.',
              error: snapshot.error,
              stackTrace: snapshot.stackTrace,
            );
          }

          final places = snapshot.hasData ? snapshot.data! : const <Lieu>[];
          final markers = places
              .where(_hasValidCoordinates)
              .map(_buildMarker)
              .toList(growable: false);

          return Stack(
            fit: StackFit.expand,
            children: [
              _CampusMap(markers: markers, onTap: _openAddLieuPage),
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
    return place.latitude != 0 || place.longitude != 0;
  }

  Marker _buildMarker(Lieu place) {
    return Marker(
      point: LatLng(
        place.latitude != 0 ? place.latitude : 0,
        place.longitude != 0 ? place.longitude : 0,
      ),
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

  void _openAddLieuPage(LatLng point) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddLieuPage(
          initialLatitude: point.latitude,
          initialLongitude: point.longitude,
        ),
      ),
    );
  }
}

class _CampusMap extends StatelessWidget {
  final List<Marker> markers;
  final ValueChanged<LatLng> onTap;

  const _CampusMap({required this.markers, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _MapPageState._campusCenter,
        initialZoom: 16,
        minZoom: 3,
        maxZoom: 19,
        onTap: (_, point) => onTap(point),
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
