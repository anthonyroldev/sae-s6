import '../models/admin_metrics.dart';

/// Source for administrator dashboard metrics.
abstract interface class AdminMetricsSource {
  /// Fetches a fresh dashboard metrics snapshot.
  Future<AdminMetrics> fetch();
}
