import 'dart:developer' as developer;

/// Centralized application logger.
abstract final class AppLogger {
  static const _name = 'le_repere';

  /// Logs an informational event.
  static void info(String message) {
    developer.log(message, name: _name);
  }

  /// Logs a warning event.
  static void warning(String message) {
    developer.log(message, name: _name, level: 900);
  }

  /// Logs an error event with optional details.
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: _name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
