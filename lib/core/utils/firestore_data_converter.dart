/// Converts loose Firestore values to app model types.
abstract final class FirestoreDataConverter {
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

  static DateTime toDateTime(Object? value) {
    if (value is DateTime) {
      return value;
    }
    try {
      final dynamic raw = value;
      final result = raw?.toDate();
      if (result is DateTime) {
        return result;
      }
    } on Object {
      return DateTime.tryParse(value?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }
}
