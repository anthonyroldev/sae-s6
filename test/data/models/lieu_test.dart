import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/data/models/lieu.dart';

void main() {
  group('Lieu.toMap', () {
    test('omits empty generated id', () {
      final map = const Lieu(nom: 'BU', description: 'Bibliotheque').toMap();

      expect(map, isNot(contains('id')));
    });

    test('keeps existing id', () {
      final map = const Lieu(
        id: 'bu',
        nom: 'BU',
        description: 'Bibliotheque',
      ).toMap();

      expect(map['id'], 'bu');
    });

    test('stores validation flag', () {
      final map = const Lieu(
        nom: 'Autoroute',
        description: '',
        isValidated: false,
      ).toMap();

      expect(map['is_validated'], isFalse);
    });
  });

  group('Lieu.fromMap', () {
    test('defaults missing validation flag to true', () {
      final lieu = Lieu.fromMap({'nom': 'BU', 'description': ''});

      expect(lieu.isValidated, isTrue);
    });

    test('reads validation flag', () {
      final lieu = Lieu.fromMap({
        'nom': 'Autoroute',
        'description': '',
        'is_validated': false,
      });

      expect(lieu.isValidated, isFalse);
    });
  });
}
