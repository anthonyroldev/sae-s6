/// Mock review shown on the profile page.
class ProfileReview {
  /// Reviewed place name.
  final String placeName;

  /// Relative review date.
  final String date;

  /// Rating from 0 to 5.
  final int rating;

  /// Review body.
  final String comment;

  /// Creates a profile review.
  const ProfileReview({
    required this.placeName,
    required this.date,
    required this.rating,
    required this.comment,
  });
}
