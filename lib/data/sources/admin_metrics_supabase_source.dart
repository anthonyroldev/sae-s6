import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/supabase_data_converter.dart';
import '../models/admin_metrics.dart';
import 'admin_metrics_source.dart';

/// Supabase implementation for administrator dashboard metrics.
class AdminMetricsSupabaseSource implements AdminMetricsSource {
  final SupabaseClient _client;

  /// Creates a Supabase source for administrator dashboard metrics.
  AdminMetricsSupabaseSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<AdminMetrics> fetch() async {
    final stopwatch = Stopwatch()..start();

    final lieuRows = await _client.from('lieux').select(
      'categorie, image_url, heure_ouverture, heure_fermeture, is_validated',
    );
    final avisRows = await _client
        .from('avis')
        .select('note, id_lieu, created_at');
    stopwatch.stop();

    final publishedLieuRows = lieuRows
        .where((row) => row['is_validated'] != false)
        .toList(growable: false);
    final totalReviews = avisRows.length;
    final totalNotes = avisRows.fold<double>(
      0,
      (sum, row) => sum + SupabaseDataConverter.toDouble(row['note']),
    );
    final reviewedPlaces = avisRows
        .map((row) => SupabaseDataConverter.toStringValue(row['id_lieu']))
        .where((id) => id.isNotEmpty)
        .toSet()
        .length;
    final placesWithImage = publishedLieuRows
        .where(
          (row) =>
              SupabaseDataConverter.toStringValue(row['image_url']).isNotEmpty,
        )
        .length;
    final placesWithHours = publishedLieuRows
        .where(
          (row) =>
              SupabaseDataConverter.toStringValue(
                row['heure_ouverture'],
              ).isNotEmpty &&
              SupabaseDataConverter.toStringValue(
                row['heure_fermeture'],
              ).isNotEmpty,
        )
        .length;
    final topCategory = _topCategory(publishedLieuRows);

    return AdminMetrics(
      totalPlaces: publishedLieuRows.length,
      totalReviews: totalReviews,
      averageReview: totalReviews == 0 ? 0 : totalNotes / totalReviews,
      reviewedPlaces: reviewedPlaces,
      placesWithImage: placesWithImage,
      placesWithHours: placesWithHours,
      topCategoryLabel: topCategory.label,
      topCategoryCount: topCategory.count,
      loadDuration: stopwatch.elapsed,
    );
  }

  ({String label, int count}) _topCategory(List<Map<String, dynamic>> rows) {
    final counts = <String, int>{};
    for (final row in rows) {
      final category = SupabaseDataConverter.toStringValue(row['categorie']);
      if (category.isEmpty) {
        continue;
      }
      counts[category] = (counts[category] ?? 0) + 1;
    }
    if (counts.isEmpty) {
      return (label: 'Aucune', count: 0);
    }

    final entries = counts.entries.toList()
      ..sort((first, second) => second.value.compareTo(first.value));
    final top = entries.first;
    return (label: top.key, count: top.value);
  }
}
