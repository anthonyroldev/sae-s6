/// Local notifications for review moderation results.
abstract interface class ReviewNotificationSource {
  /// Initializes the notification backend.
  Future<void> initialize();

  /// Requests notification permissions when the current platform needs it.
  Future<void> requestPermissions();

  /// Shows the review moderation result.
  Future<void> showReviewStatus({
    required int reviewId,
    required String status,
  });
}
