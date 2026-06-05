import 'package:le_repere/core/notifications/review_notification_source.dart';

class FakeReviewNotificationSource implements ReviewNotificationSource {
  final List<({int reviewId, String status})> shown = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> showReviewStatus({
    required int reviewId,
    required String status,
  }) async {
    shown.add((reviewId: reviewId, status: status));
  }
}
