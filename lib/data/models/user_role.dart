/// Application role attached to an authenticated user.
///
/// Stored as the Postgres enum `user_role` on `utilisateurs.role` and surfaced
/// in the access token through the `user_role` claim (custom access token
/// hook), so it can be read client-side without an extra query.
enum UserRole {
  /// Standard signed-in user. Default role for every new account.
  utilisateur('utilisateur', 'Utilisateur'),

  /// Can moderate user-submitted content (e.g. validate place proposals).
  moderateur('moderateur', 'Modérateur'),

  /// Campus association account managing its own places.
  association('association', 'Association'),

  /// Full administrative rights.
  admin('admin', 'Administrateur');

  /// Raw value stored in the database and the JWT claim.
  final String value;

  /// Human-readable label for display.
  final String label;

  const UserRole(this.value, this.label);

  /// Builds a role from a raw back-end/JWT value.
  ///
  /// Falls back to [UserRole.utilisateur] for unknown, empty, or missing input.
  static UserRole fromValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    for (final role in UserRole.values) {
      if (role.value == normalized) {
        return role;
      }
    }
    return UserRole.utilisateur;
  }

  /// Whether this role has full administrative rights.
  bool get isAdmin => this == UserRole.admin;

  /// Whether this role can moderate content (admins and moderators).
  bool get canModerate => this == UserRole.admin || this == UserRole.moderateur;
}
