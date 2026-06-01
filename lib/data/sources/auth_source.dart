/// Authentication backend contract used by the presentation layer.
///
/// Keeps Supabase types out of the UI so screens can be tested with a fake.
abstract interface class AuthSource {
  /// Sends a one-time login code to [email].
  ///
  /// When [shouldCreateUser] is false, unknown emails are rejected.
  Future<void> sendCode({
    required String email,
    required bool shouldCreateUser,
  });

  /// Verifies the [code] received by [email]; signs the user in on success.
  ///
  /// Saves [name] when verification completes a signup flow.
  Future<void> verifyCode({
    required String email,
    required String code,
    String? name,
  });

  /// Signs the current user out.
  Future<void> signOut();

  /// Whether a session is currently active.
  bool get isSignedIn;

  /// Emits `true` when a session becomes active, `false` when it ends.
  Stream<bool> get authStateChanges;
}
