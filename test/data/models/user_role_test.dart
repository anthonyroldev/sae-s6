import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/data/models/user_role.dart';

void main() {
  group('UserRole.fromValue', () {
    test('maps known database values', () {
      expect(UserRole.fromValue('utilisateur'), UserRole.utilisateur);
      expect(UserRole.fromValue('moderateur'), UserRole.moderateur);
      expect(UserRole.fromValue('association'), UserRole.association);
      expect(UserRole.fromValue('admin'), UserRole.admin);
    });

    test('normalizes case and surrounding whitespace', () {
      expect(UserRole.fromValue('  ADMIN '), UserRole.admin);
    });

    test('defaults to utilisateur for unknown, empty, or null input', () {
      expect(UserRole.fromValue('superadmin'), UserRole.utilisateur);
      expect(UserRole.fromValue(''), UserRole.utilisateur);
      expect(UserRole.fromValue(null), UserRole.utilisateur);
    });
  });

  group('role capabilities', () {
    test('only admin is admin', () {
      expect(UserRole.admin.isAdmin, isTrue);
      expect(UserRole.moderateur.isAdmin, isFalse);
      expect(UserRole.association.isAdmin, isFalse);
      expect(UserRole.utilisateur.isAdmin, isFalse);
    });

    test('admins and moderators can moderate', () {
      expect(UserRole.admin.canModerate, isTrue);
      expect(UserRole.moderateur.canModerate, isTrue);
      expect(UserRole.association.canModerate, isFalse);
      expect(UserRole.utilisateur.canModerate, isFalse);
    });
  });
}
