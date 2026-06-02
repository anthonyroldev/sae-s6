import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/data/models/lieu.dart';
import 'package:le_repere/data/models/proposition_lieu.dart';

void main() {
  group('PropositionStatut.fromValue', () {
    test('maps known values', () {
      expect(PropositionStatut.fromValue('en_attente'),
          PropositionStatut.enAttente);
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
        'nom': 'Foyer',
        'description': 'Salle de pause',
        'latitude': 50.35,
        'longitude': 3.52,
        'heure_ouverture': '08:00',
        'heure_fermeture': '18:00',
        'image_url': 'http://img',
        'categorie': 'services',
        'statut': 'en_attente',
        'id_utilisateur': 'user-1',
      });

      expect(proposition.id, 7);
      expect(proposition.nom, 'Foyer');
      expect(proposition.categorie, LieuCategorie.services);
      expect(proposition.statut, PropositionStatut.enAttente);
      expect(proposition.heures, '08:00 - 18:00');
      expect(proposition.idUtilisateur, 'user-1');
    });
  });

  group('PropositionLieu.toInsertMap', () {
    test('omits server-managed columns and empty author', () {
      const proposition = PropositionLieu(
        nom: 'Foyer',
        description: 'Salle de pause',
        categorie: LieuCategorie.repas,
      );
      final map = proposition.toInsertMap();

      expect(map.containsKey('id_proposition'), isFalse);
      expect(map.containsKey('statut'), isFalse);
      expect(map.containsKey('id_administrateur'), isFalse);
      expect(map.containsKey('id_lieu'), isFalse);
      expect(map.containsKey('id_utilisateur'), isFalse);
      expect(map['categorie'], 'repas');
    });

    test('includes the author and formatted hours when set', () {
      const proposition = PropositionLieu(
        nom: 'Foyer',
        description: '',
        heureOuverture: Duration(hours: 8),
        heureFermeture: Duration(hours: 18, minutes: 30),
        idUtilisateur: 'user-1',
      );
      final map = proposition.toInsertMap();

      expect(map['id_utilisateur'], 'user-1');
      expect(map['heure_ouverture'], '08:00');
      expect(map['heure_fermeture'], '18:30');
    });
  });
}
