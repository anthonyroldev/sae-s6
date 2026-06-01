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
  Future<void> sendCode(String email) {
    return _client.auth.signInWithOtp(email: email, shouldCreateUser: true);
  }

  @override
  Future<void> verifyCode({required String email, required String code}) async {
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
      await _client.from(_usersTable).upsert({
        'id': user.id,
        'email': user.email ?? email,
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
