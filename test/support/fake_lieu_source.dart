import 'package:le_repere/data/models/lieu.dart';
import 'package:le_repere/data/sources/lieu_supabase_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// In-memory [LieuSupabaseSource] for widget tests.
///
/// Overrides [watchAll] with a controlled stream and never touches the stub
/// Supabase client passed to `super`.
class FakeLieuSource extends LieuSupabaseSource {
  /// Places emitted by [watchAll].
  final List<Lieu> places;

  /// Creates a fake place source emitting [places].
  FakeLieuSource(this.places)
    : super(
        client: SupabaseClient(
          'https://stub.supabase.co',
          'stub-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ),
      );

  @override
  Stream<List<Lieu>> watchAll() => Stream.value(places);
}
