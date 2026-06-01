/// Converts loose back-end values (Supabase/JSON) to app model types.
abstract final class FirestoreDataConverter {
  static final _horaireRegex = RegExp(
    r'^([01]?\d|2[0-3]):([0-5]\d)\s*-\s*([01]?\d|2[0-3]):([0-5]\d)$',
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

  static String toHoraire(Object? value) {
    if (value is Map) {
      final start = value['debut'] ?? value['start'] ?? value['ouverture'];
      final end = value['fin'] ?? value['end'] ?? value['fermeture'];
      return _normalizeHoraire(
        '${_normalizeHour(start)} - ${_normalizeHour(end)}',
      );
    }
    if (value is List && value.length >= 2) {
      return _normalizeHoraire(
        '${_normalizeHour(value[0])} - ${_normalizeHour(value[1])}',
      );
    }
    return _normalizeHoraire(toStringValue(value));
  }

  /// Returns whether the current timestamp is inside the opening hours.
  static bool isOpenFromHoraire({
    required Object? currentTimestamp,
    required String heures,
  }) {
    final normalized = toHoraire(heures);
    final match = _horaireRegex.firstMatch(normalized);
    if (match == null) {
      return false;
    }

    final now = toDateTime(currentTimestamp);
    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = toInt(match.group(1)) * 60 + toInt(match.group(2));
    final endMinutes = toInt(match.group(3)) * 60 + toInt(match.group(4));

    if (startMinutes <= endMinutes) {
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

  static String _normalizeHoraire(String value) {
    final normalized = value
        .trim()
        .replaceAll('h', ':')
        .replaceAll('H', ':')
        .replaceAll('–', '-')
        .replaceAll('—', '-');
    final match = _horaireRegex.firstMatch(normalized);
    if (match == null) {
      return normalized;
    }
    final startHour = toInt(match.group(1)).toString().padLeft(2, '0');
    final endHour = toInt(match.group(3)).toString().padLeft(2, '0');
    return '$startHour:${match.group(2)} - $endHour:${match.group(4)}';
  }

  static String _normalizeHour(Object? value) {
    return toStringValue(
      value,
    ).trim().replaceAll('h', ':').replaceAll('H', ':');
  }
}
