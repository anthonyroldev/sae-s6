import '../../core/utils/supabase_data_converter.dart';

/// Proposed place ready for Firestore reads and writes.
class PropositionLieu {
  final int idProposition;
  final String statut;
  final int idLieu;
  final String idUtilisateur;
  final String idAdministrateur;

  /// Creates a place proposal.
  const PropositionLieu({
    required this.idProposition,
    required this.statut,
    required this.idLieu,
    required this.idUtilisateur,
    this.idAdministrateur = '',
  });

  /// Creates a proposal from Firestore data.
  factory PropositionLieu.fromMap(Map<String, dynamic> map) {
    return PropositionLieu(
      idProposition: SupabaseDataConverter.toInt(map['idProposition']),
      statut: SupabaseDataConverter.toStringValue(map['statut']),
      idLieu: SupabaseDataConverter.toInt(map['idLieu']),
      idUtilisateur: SupabaseDataConverter.toStringValue(map['idUtilisateur']),
      idAdministrateur: SupabaseDataConverter.toStringValue(
        map['idAdministrateur'],
      ),
    );
  }

  /// Converts this proposal to Firestore data.
  Map<String, dynamic> toMap() {
    return {
      'idProposition': idProposition,
      'statut': statut,
      'idLieu': idLieu,
      'idUtilisateur': idUtilisateur,
      'idAdministrateur': idAdministrateur,
    };
  }
}
