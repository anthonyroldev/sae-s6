/// Authentication backend contract used by the presentation layer.
///
/// Keeps Supabase types out of the UI so screens can be tested with a fake.
abstract interface class AuthSource {
  /// Signs in an existing user with [email] and [password].
  Future<void> signIn({required String email, required String password});

  /// Creates an account with [email] and [password], then saves [name].
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  });

  /// Signs the current user out.
  Future<void> signOut();

  /// Whether a session is currently active.
  bool get isSignedIn;

  /// Emits `true` when a session becomes active, `false` when it ends.
  Stream<bool> get authStateChanges;
}
