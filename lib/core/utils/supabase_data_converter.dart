/// Converts loose back-end values (Supabase/JSON) to app model types.
abstract final class SupabaseDataConverter {
  static final _timeRegex = RegExp(
    r'^([01]?\d|2[0-3]):([0-5]\d)(?::([0-5]\d)(?:\.\d+)?)?$',
  );

  static int toInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool toBool(Object? value) {
    if (value is bool) {
      return value;
    }
    return value?.toString().toLowerCase() == 'true';
  }

  /// Converts a value to a string.
  static String toStringValue(Object? value) {
    return value?.toString() ?? '';
  }

  /// Converts a PostgreSQL time value to a duration since midnight.
  static Duration? toTimeOfDay(Object? value) {
    if (value is Duration) {
      return value;
    }
    final match = _timeRegex.firstMatch(toStringValue(value).trim());
    if (match == null) {
      return null;
    }
    return Duration(
      hours: toInt(match.group(1)),
      minutes: toInt(match.group(2)),
      seconds: toInt(match.group(3)),
    );
  }

  /// Formats a duration since midnight for PostgreSQL.
  static String? formatTimeOfDay(Duration? value) {
    if (value == null) {
      return null;
    }
    final hours = value.inHours.toString().padLeft(2, '0');
    final minutes = (value.inMinutes % Duration.minutesPerHour)
        .toString()
        .padLeft(2, '0');
    return '$hours:$minutes';
  }

  /// Returns whether the current timestamp is inside the opening hours.
  static bool isOpenAt({
    required Object? currentTimestamp,
    required Duration? heureOuverture,
    required Duration? heureFermeture,
  }) {
    if (heureOuverture == null || heureFermeture == null) {
      return false;
    }

    final now = toDateTime(currentTimestamp);
    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = heureOuverture.inMinutes;
    final endMinutes = heureFermeture.inMinutes;

    if (startMinutes == endMinutes) {
      return true;
    }
    if (startMinutes < endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    }
    return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
  }

  static DateTime toDateTime(Object? value) {
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }
}
