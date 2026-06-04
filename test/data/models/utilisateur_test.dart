import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/data/models/user_role.dart';
import 'package:le_repere/data/models/utilisateur.dart';

void main() {
  group('Utilisateur.fromMap', () {
    test('reads the role column', () {
      final user = Utilisateur.fromMap({
        'id': 'u1',
        'nom': 'Alice',
        'email': 'alice@uphf.fr',
        'position_gps': '',
        'role': 'admin',
      });
      expect(user.role, UserRole.admin);
    });

    test('defaults to utilisateur when role is missing', () {
      final user = Utilisateur.fromMap({
        'id': 'u1',
        'nom': 'Bob',
        'email': 'bob@uphf.fr',
        'position_gps': '',
      });
      expect(user.role, UserRole.utilisateur);
    });
  });

  test('toMap omits the server-managed role column', () {
    const user = Utilisateur(
      id: 'u1',
      nom: 'Alice',
      email: 'alice@uphf.fr',
      positionGps: '',
      role: UserRole.admin,
    );
    expect(user.toMap().containsKey('role'), isFalse);
  });
}
