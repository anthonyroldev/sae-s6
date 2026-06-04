import '../models/lieu.dart';

/// Favorite places backend contract.
abstract interface class FavorisSource {
  /// Watches the current user's favorite place identifiers.
  Stream<Set<String>> watchCurrentUserPlaceIds();

  /// Watches the current user's favorite places.
  Stream<List<Lieu>> watchCurrentUserPlaces();

  /// Adds or removes [lieuId] from the current user's favorites.
  Future<void> setFavorite({required String lieuId, required bool isFavorite});
}
