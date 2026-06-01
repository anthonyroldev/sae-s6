/// Authentication backend contract used by the presentation layer.
///
/// Keeps Supabase types out of the UI so screens can be tested with a fake.
abstract interface class AuthSource {
  /// Sends a one-time login code to [email].
  Future<void> sendCode(String email);

  /// Verifies the [code] received by [email]; signs the user in on success.
  Future<void> verifyCode({required String email, required String code});

  /// Signs the current user out.
  Future<void> signOut();

  /// Whether a session is currently active.
  bool get isSignedIn;

  /// Emits `true` when a session becomes active, `false` when it ends.
  Stream<bool> get authStateChanges;
}
