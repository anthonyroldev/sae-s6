import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'review_notification_source.dart';

/// Local notification implementation for review moderation results.
class LocalReviewNotificationSource implements ReviewNotificationSource {
  static const _channelId = 'review_moderation';
  static const _channelName = 'Modération des avis';
  static const _channelDescription = 'Résultats de validation des avis';

  static final LocalReviewNotificationSource instance =
      LocalReviewNotificationSource._();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  LocalReviewNotificationSource._()
    : _plugin = FlutterLocalNotificationsPlugin();

  /// Creates a notification source with a custom plugin.
  LocalReviewNotificationSource({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  @override
  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  @override
  Future<void> showReviewStatus({
    required int reviewId,
    required String status,
  }) async {
    final body = switch (status) {
      'accepted' => 'Votre avis a été accepté',
      'denied' => 'Votre avis a été refusé',
      _ => null,
    };
    if (body == null) return;

    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);

    await _plugin.show(
      id: reviewId,
      title: 'Avis modéré',
      body: body,
      notificationDetails: details,
    );
  }
}
