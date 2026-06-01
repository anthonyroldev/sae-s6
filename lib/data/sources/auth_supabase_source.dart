import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_source.dart';

/// Supabase (GoTrue) implementation of [AuthSource] using email OTP codes.
class AuthSupabaseSource implements AuthSource {
  static const _usersTable = 'utilisateurs';

  final SupabaseClient _client;

  /// Creates a Supabase auth source.
  AuthSupabaseSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<void> sendCode({
    required String email,
    required bool shouldCreateUser,
  }) {
    return _client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: shouldCreateUser,
    );
  }

  @override
  Future<void> verifyCode({
    required String email,
    required String code,
    String? name,
  }) async {
    final response = await _client.auth.verifyOTP(
      type: OtpType.email,
      token: code,
      email: email,
    );
    if (response.session == null) {
      throw const AuthException('Aucune session créée');
    }
    final user = response.user;
    if (user != null) {
      final existingProfile = await _client
          .from(_usersTable)
          .select('nom')
          .eq('id', user.id)
          .maybeSingle();
      final existingName = existingProfile?['nom']?.toString() ?? '';
      await _client.from(_usersTable).upsert({
        'id': user.id,
        'email': user.email ?? email,
        'nom': name?.trim().isNotEmpty == true ? name!.trim() : existingName,
      }, onConflict: 'id');
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  bool get isSignedIn => _client.auth.currentSession != null;

  @override
  Stream<bool> get authStateChanges =>
      _client.auth.onAuthStateChange.map((state) => state.session != null);
}
