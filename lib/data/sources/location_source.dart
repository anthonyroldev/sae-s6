import 'package:latlong2/latlong.dart';

/// Watches the current device position.
abstract class LocationSource {
  /// Emits the user's current position and future updates.
  Stream<LatLng> watchCurrentPosition();
}
