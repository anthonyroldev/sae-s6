import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Initializes Firebase when the current platform has generated options.
abstract final class AppFirebase {
  static bool _isEnabled = false;

  /// Whether Firebase is available for the current platform.
  static bool get isEnabled => _isEnabled || Firebase.apps.isNotEmpty;

  /// Initializes Firebase and keeps the app running if a platform is missing.
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isEnabled = true;
    } on UnsupportedError catch (error) {
      debugPrint('Firebase disabled: $error');
      _isEnabled = false;
    }
  }
}
