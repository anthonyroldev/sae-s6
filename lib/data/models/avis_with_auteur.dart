import '../../core/utils/supabase_data_converter.dart';
import 'avis.dart';

/// Review enriched with the author's display name.
class AvisWithAuteur {
  final Avis avis;
  final String nomAuteur;

  const AvisWithAuteur({required this.avis, required this.nomAuteur});

  factory AvisWithAuteur.fromMap(Map<String, dynamic> map) {
    final utilisateur = map['utilisateurs'] as Map<String, dynamic>?;
    final nom = utilisateur != null
        ? SupabaseDataConverter.toStringValue(utilisateur['nom'])
        : '';
    return AvisWithAuteur(
      avis: Avis.fromMap(map),
      nomAuteur: nom.isEmpty ? 'Anonyme' : nom,
    );
  }
}