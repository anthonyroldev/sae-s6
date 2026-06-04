/// Aggregated metrics displayed in the administrator dashboard.
class AdminMetrics {
  /// Total number of rows in `lieux`.
  final int totalPlaces;

  /// Total number of rows in `avis`.
  final int totalReviews;

  /// Average of all review notes.
  final double averageReview;

  /// Number of places with at least one review.
  final int reviewedPlaces;

  /// Number of places with a usable image.
  final int placesWithImage;

  /// Number of places with opening and closing hours.
  final int placesWithHours;

  /// Most represented place category label.
  final String topCategoryLabel;

  /// Number of places in the most represented category.
  final int topCategoryCount;

  /// Time taken to load dashboard metrics.
  final Duration loadDuration;

  /// Creates an administrator metrics snapshot.
  const AdminMetrics({
    required this.totalPlaces,
    required this.totalReviews,
    required this.averageReview,
    required this.reviewedPlaces,
    required this.placesWithImage,
    required this.placesWithHours,
    required this.topCategoryLabel,
    required this.topCategoryCount,
    required this.loadDuration,
  });

  /// Percentage of places that received at least one review.
  double get reviewedPlaceRate {
    if (totalPlaces == 0) {
      return 0;
    }
    return reviewedPlaces / totalPlaces;
  }

  /// Percentage of places with a usable image.
  double get imageCoverageRate {
    if (totalPlaces == 0) {
      return 0;
    }
    return placesWithImage / totalPlaces;
  }

  /// Percentage of places with configured opening hours.
  double get hoursCoverageRate {
    if (totalPlaces == 0) {
      return 0;
    }
    return placesWithHours / totalPlaces;
  }

  /// Average number of reviews per place.
  double get reviewsPerPlace {
    if (totalPlaces == 0) {
      return 0;
    }
    return totalReviews / totalPlaces;
  }
}
