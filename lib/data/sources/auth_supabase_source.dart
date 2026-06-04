import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_source.dart';

/// Supabase (GoTrue) implementation of [AuthSource] using email and password.
class AuthSupabaseSource implements AuthSource {
  static const _usersTable = 'utilisateurs';

  final SupabaseClient _client;

  /// Creates a Supabase auth source.
  AuthSupabaseSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<void> signIn({required String email, required String password}) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.session == null) {
      throw const AuthException('Aucune session creee');
    }
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'nom': name.trim()},
    );
    if (response.session == null) {
      throw const AuthException(
        'Confirmation email activee dans Supabase. Desactivez-la dans Auth > Providers > Email.',
      );
    }
    final user = response.user;
    if (user == null) {
      throw const AuthException('Aucun utilisateur cree');
    }
    await _client.from(_usersTable).upsert({
      'id': user.id,
      'email': user.email ?? email,
      'nom': name.trim(),
    }, onConflict: 'id');
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  bool get isSignedIn => _client.auth.currentSession != null;

  @override
  Stream<bool> get authStateChanges =>
      _client.auth.onAuthStateChange.map((state) => state.session != null);
}
