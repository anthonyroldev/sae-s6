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
  });
}
