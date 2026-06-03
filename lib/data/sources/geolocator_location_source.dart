import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'location_access_exception.dart';
import 'location_source.dart';

/// Location source backed by the Geolocator plugin.
class GeolocatorLocationSource implements LocationSource {
  static const _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 1,
  );

  /// Creates a Geolocator-backed location source.
  const GeolocatorLocationSource();

  @override
  Stream<LatLng> watchCurrentPosition() async* {
    await _ensureLocationAccess();

    final currentPosition = await Geolocator.getCurrentPosition(
      locationSettings: _settings,
    );
    yield _toLatLng(currentPosition);

    yield* Geolocator.getPositionStream(
      locationSettings: _settings,
    ).map(_toLatLng);
  }

  Future<void> _ensureLocationAccess() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationAccessException(
        'Activez la localisation pour afficher votre position.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationAccessException('Permission de localisation refusée.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationAccessException(
        'Autorisez la localisation dans les réglages pour afficher votre position.',
      );
    }
  }

  LatLng _toLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }
}
