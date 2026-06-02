import 'dart:async';

import 'package:le_repere/data/models/user_role.dart';
import 'package:le_repere/data/sources/role_source.dart';

/// In-memory [RoleSource] for widget tests.
class FakeRoleSource implements RoleSource {
  /// Current role returned by [currentRole].
  UserRole role;

  /// Role updates passed to [setUserRole], in order.
  final List<({String userId, UserRole role})> updates = [];

  final StreamController<UserRole> _controller =
      StreamController<UserRole>.broadcast();

  /// Creates a fake role source defaulting to [UserRole.utilisateur].
  FakeRoleSource({this.role = UserRole.utilisateur});

  @override
  UserRole get currentRole => role;

  @override
  Stream<UserRole> get roleChanges => _controller.stream;

  @override
  Future<void> setUserRole({
    required String userId,
    required UserRole role,
  }) async {
    updates.add((userId: userId, role: role));
  }

  /// Emits a new [role] on [roleChanges].
  void emit(UserRole newRole) {
    role = newRole;
    _controller.add(newRole);
  }

  /// Closes the internal stream controller.
  void dispose() => _controller.close();
}
