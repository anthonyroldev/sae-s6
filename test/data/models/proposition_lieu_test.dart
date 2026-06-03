import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/data/models/lieu.dart';
import 'package:le_repere/data/models/proposition_lieu.dart';

void main() {
  group('PropositionStatut.fromValue', () {
    test('maps known values', () {
      expect(
        PropositionStatut.fromValue('en_attente'),
        PropositionStatut.enAttente,
      );
      expect(PropositionStatut.fromValue('validee'), PropositionStatut.validee);
      expect(PropositionStatut.fromValue('refusee'), PropositionStatut.refusee);
    });

    test('defaults to enAttente for unknown input', () {
      expect(PropositionStatut.fromValue('???'), PropositionStatut.enAttente);
      expect(PropositionStatut.fromValue(null), PropositionStatut.enAttente);
    });
  });

  group('PropositionLieu.fromMap', () {
    test('reads a Supabase row', () {
      final proposition = PropositionLieu.fromMap({
        'id_proposition': 7,
        'id_lieu': 'lieu-1',
        'statut': 'en_attente',
        'id_utilisateur': 'user-1',
        'lieux': {
          'id': 'lieu-1',
          'nom': 'Foyer',
          'description': 'Salle de pause',
          'latitude': 50.35,
          'longitude': 3.52,
          'heure_ouverture': '08:00',
          'heure_fermeture': '18:00',
          'image_url': 'http://img',
          'categorie': 'services',
        },
      });

      expect(proposition.id, 7);
      expect(proposition.nom, 'Foyer');
      expect(proposition.categorie, LieuCategorie.services);
      expect(proposition.statut, PropositionStatut.enAttente);
      expect(proposition.heures, '08:00 - 18:00');
      expect(proposition.idLieu, 'lieu-1');
      expect(proposition.idUtilisateur, 'user-1');
    });
  });

  group('PropositionLieu.toInsertMap', () {
    test('keeps only join columns', () {
      const proposition = PropositionLieu(
        nom: 'Foyer',
        description: 'Salle de pause',
        categorie: LieuCategorie.repas,
        idLieu: 'lieu-1',
      );
      final map = proposition.toInsertMap();

      expect(map.containsKey('id_proposition'), isFalse);
      expect(map.containsKey('statut'), isFalse);
      expect(map.containsKey('id_administrateur'), isFalse);
      expect(map['id_lieu'], 'lieu-1');
      expect(map.containsKey('id_utilisateur'), isFalse);
      expect(map.containsKey('categorie'), isFalse);
    });

    test('includes the author when set', () {
      const proposition = PropositionLieu(
        nom: 'Foyer',
        description: '',
        heureOuverture: Duration(hours: 8),
        heureFermeture: Duration(hours: 18, minutes: 30),
        idUtilisateur: 'user-1',
      );
      final map = proposition.toInsertMap();

      expect(map['id_utilisateur'], 'user-1');
      expect(map.containsKey('heure_ouverture'), isFalse);
      expect(map.containsKey('heure_fermeture'), isFalse);
    });

    test('converts candidate place data to a lieu row', () {
      const proposition = PropositionLieu(
        nom: 'Foyer',
        description: 'Salle de pause',
        latitude: 50.35,
        longitude: 3.52,
        heureOuverture: Duration(hours: 8),
        heureFermeture: Duration(hours: 18, minutes: 30),
        imageUrl: 'http://img',
        categorie: LieuCategorie.repas,
      );
      final map = proposition.toLieu().toMap();

      expect(map['nom'], 'Foyer');
      expect(map['categorie'], 'repas');
      expect(map['is_validated'], isFalse);
      expect(map['heure_ouverture'], '08:00');
      expect(map['heure_fermeture'], '18:30');
    });
  });
}
