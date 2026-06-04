import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/lieu.dart';

/// Public URL and storage path of an uploaded place image.
typedef UploadedImage = ({String url, String path});

/// Supabase source for campus places.
class LieuSupabaseSource {
  static const _table = 'lieux';
  static const _imageBucket = 'lieux';

  final SupabaseClient _client;
  final Random _random;

  /// Creates a Supabase source for campus places.
  LieuSupabaseSource({SupabaseClient? client, Random? random})
    : _client = client ?? Supabase.instance.client,
      _random = random ?? Random();

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

  /// Uploads a place image and returns its public URL and storage path.
  ///
  /// The caller keeps the returned [UploadedImage.path] so it can call
  /// [removeImage] if the place row ultimately fails to save, avoiding a
  /// dangling file in storage.
  Future<UploadedImage> uploadImage({
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) async {
    final path = _buildImagePath(extensionFor(fileName));
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
    final url = _client.storage.from(_imageBucket).getPublicUrl(path);
    return (url: url, path: path);
  }

  /// Removes a previously uploaded place image.
  ///
  /// A blank [path] is ignored so callers can pass the result of an upload that
  /// never happened without guarding first.
  Future<void> removeImage(String path) async {
    if (path.isEmpty) {
      return;
    }
    await _client.storage.from(_imageBucket).remove([path]);
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

  /// Builds a collision-resistant storage path for a new place image.
  String _buildImagePath(String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final suffix = _random.nextInt(1 << 30).toRadixString(16);
    return 'places/$timestamp-$suffix.$extension';
  }

  /// Returns the lowercased file extension of [fileName], defaulting to `jpg`
  /// when the name carries no usable extension.
  @visibleForTesting
  static String extensionFor(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    if (extension == fileName || extension.isEmpty) {
      return 'jpg';
    }
    return extension;
  }
}
