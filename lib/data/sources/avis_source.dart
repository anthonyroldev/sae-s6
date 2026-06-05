import '../models/avis.dart';
import '../models/avis_with_auteur.dart';

/// Review backend contract.
abstract interface class AvisSource {
  /// Current authenticated user id, or null when signed out.
  String? get currentUserId;

  /// Fetches reviews visible to the current user for a place.
  Future<List<AvisWithAuteur>> fetchForLieu(String idLieu, {int? limit});

  /// Returns public accepted review stats for a place.
  Future<({double average, int count})> fetchStats(String idLieu);

  /// Returns public accepted review stats indexed by place id.
  Future<Map<String, ({double average, int count})>> fetchStatsForLieux(
    List<String> idsLieu,
  );

  /// Adds or updates one review.
  Future<Avis> save(Avis avis);

  /// Starts server-side moderation for one review and returns its final status.
  Future<String> moderateReview(Avis avis);
}
