import '../models/user_role.dart';

/// Application role backend contract.
///
/// Keeps Supabase types out of the UI so screens can be tested with a fake.
abstract interface class RoleSource {
  /// The current user's role, or [UserRole.utilisateur] when signed out.
  UserRole get currentRole;

  /// Emits the user's role whenever the auth state changes.
  Stream<UserRole> get roleChanges;

  /// Promotes or demotes [userId] to [role] (administrators only).
  Future<void> setUserRole({required String userId, required UserRole role});
}
