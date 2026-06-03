/// Exception shown when the app cannot access the user's current position.
class LocationAccessException implements Exception {
  /// User-facing message explaining why location is unavailable.
  final String message;

  /// Creates a location access exception.
  const LocationAccessException(this.message);
}
