import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/lieu.dart';

/// Supabase source for campus places.
class LieuSupabaseSource {
  static const _table = 'lieux';
  static const _imageBucket = 'lieux';

  final SupabaseClient _client;

  /// Creates a Supabase source for campus places.
  LieuSupabaseSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Watches all campus places, ordered by name.
  Stream<List<Lieu>> watchAll() {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('nom')
        .map(
          (rows) => rows
              .map(Lieu.fromMap)
              .where((lieu) => lieu.isValidated)
              .toList(growable: false),
        );
  }

  /// Creates a campus place.
  Future<void> save(Lieu lieu) {
    _validateLieu(lieu);
    return _client.from(_table).insert(lieu.toMap());
  }

  /// Uploads a place image and returns its public URL.
  Future<String> uploadImage({
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) async {
    final extension = _extensionFrom(fileName);
    final path = 'places/${DateTime.now().millisecondsSinceEpoch}.$extension';
    await _client.storage
        .from(_imageBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType ?? 'image/jpeg',
            upsert: false,
          ),
        );
    return _client.storage.from(_imageBucket).getPublicUrl(path);
  }

  void _validateLieu(Lieu lieu) {
    if (lieu.nom.trim().isEmpty) {
      throw ArgumentError.value(lieu.nom, 'nom');
    }
    if (lieu.latitude < -90 || lieu.latitude > 90) {
      throw ArgumentError.value(lieu.latitude, 'latitude');
    }
    if (lieu.longitude < -180 || lieu.longitude > 180) {
      throw ArgumentError.value(lieu.longitude, 'longitude');
    }
  }

  String _extensionFrom(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    if (extension == fileName || extension.isEmpty) {
      return 'jpg';
    }
    return extension;
  }
}
