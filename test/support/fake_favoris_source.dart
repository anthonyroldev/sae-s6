import 'package:le_repere/data/models/lieu.dart';
import 'package:le_repere/data/sources/favoris_source.dart';

/// In-memory [FavorisSource] for widget tests.
class FakeFavorisSource implements FavorisSource {
  final Stream<List<Lieu>> placesStream;
  final Stream<Set<String>> idsStream;
  final List<({String lieuId, bool isFavorite})> updates = [];

  /// Creates a fake favorite source.
  FakeFavorisSource({
    Stream<List<Lieu>>? placesStream,
    Stream<Set<String>>? idsStream,
  }) : placesStream = placesStream ?? Stream.value(const <Lieu>[]),
       idsStream = idsStream ?? Stream.value(const <String>{});

  @override
  Future<void> setFavorite({
    required String lieuId,
    required bool isFavorite,
  }) async {
    updates.add((lieuId: lieuId, isFavorite: isFavorite));
  }

  @override
  Stream<Set<String>> watchCurrentUserPlaceIds() => idsStream;

  @override
  Stream<List<Lieu>> watchCurrentUserPlaces() => placesStream;
}
