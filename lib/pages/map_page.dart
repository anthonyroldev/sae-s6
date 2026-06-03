import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/utils/logger.dart';
import '../data/models/lieu.dart';
import '../data/sources/geolocator_location_source.dart';
import '../data/sources/lieu_supabase_source.dart';
import '../data/sources/location_access_exception.dart';
import '../data/sources/location_source.dart';
import 'add_lieu_page.dart';
import 'feed/place_category_icon.dart';
import 'feed/status_badge.dart';
import 'lieu_detail_page.dart';

/// Campus map page.
class MapPage extends StatefulWidget {
  /// Place stream displayed on the campus map.
  final Stream<List<Lieu>>? lieuxStream;

  /// Location source used to display the current user position.
  final LocationSource locationSource;

  /// Creates the campus map page.
  const MapPage({
    super.key,
    this.lieuxStream,
    this.locationSource = const GeolocatorLocationSource(),
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _campusCenter = LatLng(50.3559, 3.5182);
  final _mapController = MapController();
  late final Stream<List<Lieu>> _lieuxStream;
  StreamSubscription<LatLng>? _positionSubscription;
  LatLng? _userPosition;
  Lieu? _selectedPlace;
  bool _hasCenteredOnUser = false;

  @override
  void initState() {
    super.initState();
    _lieuxStream = widget.lieuxStream ?? LieuSupabaseSource().watchAll();
    _watchUserPosition();
  }

  @override
  void dispose() {
    unawaited(_positionSubscription?.cancel());
    super.dispose();
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
          final selectedPlace = _selectedPlace;
          final markers = places
              .where(_hasValidCoordinates)
              .map(_buildMarker)
              .toList(growable: false);

          return Stack(
            fit: StackFit.expand,
            children: [
              _CampusMap(
                mapController: _mapController,
                markers: markers,
                userPosition: _userPosition,
                onTap: _openAddLieuPage,
              ),
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
              if (selectedPlace != null)
                _SelectedPlacePanel(
                  place: selectedPlace,
                  onDetailsPressed: () => _openPlaceDetails(selectedPlace),
                ),
            ],
          );
        },
      ),
    );
  }

  void _watchUserPosition() {
    _positionSubscription = widget.locationSource.watchCurrentPosition().listen(
      _updateUserPosition,
      onError: _handleLocationError,
    );
  }

  void _updateUserPosition(LatLng position) {
    if (!mounted) {
      return;
    }

    setState(() => _userPosition = position);

    if (_hasCenteredOnUser) {
      return;
    }

    _hasCenteredOnUser = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _mapController.move(position, 16);
      }
    });
  }

  void _handleLocationError(Object error, StackTrace stackTrace) {
    if (!mounted) {
      return;
    }

    logger.e(
      'Failed to watch current position.',
      error: error,
      stackTrace: stackTrace,
    );

    final message = error is LocationAccessException
        ? error.message
        : 'Impossible de récupérer votre position.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
      child: GestureDetector(
        key: Key('place-marker-${place.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _selectedPlace = place),
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
      ),
    );
  }

  void _openAddLieuPage(LatLng point) {
    setState(() => _selectedPlace = null);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddLieuPage(
          initialLatitude: point.latitude,
          initialLongitude: point.longitude,
        ),
      ),
    );
  }

  void _openPlaceDetails(Lieu place) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LieuDetailPage(lieu: place),
      ),
    );
  }
}

class _SelectedPlacePanel extends StatelessWidget {
  final Lieu place;
  final VoidCallback onDetailsPressed;

  const _SelectedPlacePanel({
    required this.place,
    required this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Positioned(
      left: AppSpacing.md,
      right: AppSpacing.md,
      bottom: AppSpacing.md + bottomPadding,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PlaceThumbnail(place: place),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                place.nom,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            StatusBadge(isOpen: place.isOpen),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          place.categorie.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          place.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onDetailsPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Voir les détails',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceThumbnail extends StatelessWidget {
  final Lieu place;

  const _PlaceThumbnail({required this.place});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox.square(
        dimension: 66,
        child: Image.network(
          place.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => ColoredBox(
            color: AppColors.surfaceVariant,
            child: Icon(
              iconForCategory(place.categorie),
              color: AppColors.secondaryText,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

class _CampusMap extends StatelessWidget {
  final MapController mapController;
  final List<Marker> markers;
  final LatLng? userPosition;
  final ValueChanged<LatLng> onTap;

  const _CampusMap({
    required this.mapController,
    required this.markers,
    required this.userPosition,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final allMarkers = [
      ...markers,
      if (userPosition != null) _buildUserMarker(userPosition!),
    ];

    return FlutterMap(
      mapController: mapController,
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
        MarkerLayer(markers: allMarkers),
      ],
    );
  }

  Marker _buildUserMarker(LatLng position) {
    return Marker(
      point: position,
      width: 44,
      height: 44,
      child: const DecoratedBox(
        key: Key('user-position-marker'),
        decoration: BoxDecoration(
          color: Color(0x332563EB),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: 16,
                  child: Icon(
                    Icons.my_location,
                    color: AppColors.surface,
                    size: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
