import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/data/models/avis.dart';

void main() {
  group('Avis.create', () {
    test('defaults to pending moderation', () {
      final avis = Avis.create(
        note: 4,
        commentaire: 'Très bon lieu.',
        idLieu: 'lieu-1',
        idUtilisateur: 'user-1',
      );

      expect(avis.isValidated, isFalse);
      expect(avis.moderationStatus, 'pending');
    });
  });

  group('Avis.fromMap', () {
    test('reads moderation fields', () {
      final avis = Avis.fromMap({
        'id_avis': 7,
        'note': 4.5,
        'commentaire': 'Très bon lieu.',
        'created_at': '2026-06-04T10:00:00Z',
        'id_lieu': 'lieu-1',
        'id_utilisateur': 'user-1',
        'is_validated': true,
        'moderation_status': 'accepted',
      });

      expect(avis.isValidated, isTrue);
      expect(avis.moderationStatus, 'accepted');
    });
  });

  group('Avis.toMap', () {
    test('stores moderation fields', () {
      final map = Avis.create(
        note: 3,
        commentaire: 'Correct.',
        idLieu: 'lieu-1',
        idUtilisateur: 'user-1',
      ).toMap();

      expect(map['is_validated'], isFalse);
      expect(map['moderation_status'], 'pending');
    });
  });
}
