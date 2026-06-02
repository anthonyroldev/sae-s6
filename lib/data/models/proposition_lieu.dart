import '../../core/utils/supabase_data_converter.dart';
import 'lieu.dart';

/// Lifecycle status of a place proposal (matches the `proposition_statut`
/// Postgres enum).
enum PropositionStatut {
  /// Awaiting a moderator decision.
  enAttente('en_attente', 'En attente'),

  /// Validated; the place has been published.
  validee('validee', 'Validée'),

  /// Rejected by a moderator.
  refusee('refusee', 'Refusée');

  /// Raw value stored in the database.
  final String value;

  /// Human-readable label.
  final String label;

  const PropositionStatut(this.value, this.label);

  /// Builds a status from a raw value, defaulting to [enAttente].
  static PropositionStatut fromValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    for (final statut in PropositionStatut.values) {
      if (statut.value == normalized) {
        return statut;
      }
    }
    return PropositionStatut.enAttente;
  }
}

/// A user-submitted candidate place awaiting moderation.
///
/// Carries the full candidate place data; on validation it is copied into the
/// `lieux` table by the `valider_proposition` RPC.
class PropositionLieu {
  final int id;
  final String nom;
  final String description;
  final double latitude;
  final double longitude;
  final Duration? heureOuverture;
  final Duration? heureFermeture;
  final String imageUrl;
  final LieuCategorie categorie;
  final PropositionStatut statut;
  final String idLieu;
  final String idUtilisateur;
  final String idAdministrateur;

  /// Creates a place proposal.
  const PropositionLieu({
    this.id = 0,
    required this.nom,
    required this.description,
    this.latitude = 0,
    this.longitude = 0,
    this.heureOuverture,
    this.heureFermeture,
    this.imageUrl = '',
    this.categorie = LieuCategorie.services,
    this.statut = PropositionStatut.enAttente,
    this.idLieu = '',
    this.idUtilisateur = '',
    this.idAdministrateur = '',
  });

  /// Creates a proposal from a Supabase row.
  factory PropositionLieu.fromMap(Map<String, dynamic> map) {
    return PropositionLieu(
      id: SupabaseDataConverter.toInt(
        map['id_proposition'] ?? map['idProposition'],
      ),
      nom: SupabaseDataConverter.toStringValue(map['nom']),
      description: SupabaseDataConverter.toStringValue(map['description']),
      latitude: SupabaseDataConverter.toDouble(map['latitude']),
      longitude: SupabaseDataConverter.toDouble(map['longitude']),
      heureOuverture: SupabaseDataConverter.toTimeOfDay(map['heure_ouverture']),
      heureFermeture: SupabaseDataConverter.toTimeOfDay(map['heure_fermeture']),
      imageUrl: SupabaseDataConverter.toStringValue(
        map['image_url'] ?? map['imageUrl'],
      ),
      categorie: LieuCategorie.fromValue(map['categorie']),
      statut: PropositionStatut.fromValue(map['statut']),
      idLieu: SupabaseDataConverter.toStringValue(map['id_lieu'] ?? map['idLieu']),
      idUtilisateur: SupabaseDataConverter.toStringValue(
        map['id_utilisateur'] ?? map['idUtilisateur'],
      ),
      idAdministrateur: SupabaseDataConverter.toStringValue(
        map['id_administrateur'] ?? map['idAdministrateur'],
      ),
    );
  }

  /// Insert payload for a new proposal.
  ///
  /// Server-managed columns (`id_proposition`, `statut`, `id_lieu`,
  /// `id_administrateur`, `created_at`) are omitted; the client cannot set them.
  Map<String, dynamic> toInsertMap() {
    return {
      'nom': nom,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'heure_ouverture': SupabaseDataConverter.formatTimeOfDay(heureOuverture),
      'heure_fermeture': SupabaseDataConverter.formatTimeOfDay(heureFermeture),
      'image_url': imageUrl,
      'categorie': categorie.value,
      if (idUtilisateur.isNotEmpty) 'id_utilisateur': idUtilisateur,
    };
  }

  /// Opening hours label used by moderation cards.
  String get heures {
    final ouverture = SupabaseDataConverter.formatTimeOfDay(heureOuverture);
    final fermeture = SupabaseDataConverter.formatTimeOfDay(heureFermeture);
    if (ouverture == null || fermeture == null) {
      return '';
    }
    if (ouverture == fermeture) {
      return '24h/24';
    }
    return '$ouverture - $fermeture';
  }
}
