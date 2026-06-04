import '../../core/utils/supabase_data_converter.dart';

/// Place review ready for Supabase reads and writes.
class Avis {
  final int idAvis;
  final double note;
  final String commentaire;
  final DateTime date;
  final String idLieu;
  final String idUtilisateur;
  final bool isValidated;
  final String moderationStatus;

  /// Creates a place review.
  const Avis({
    this.idAvis = 0,
    required this.note,
    required this.commentaire,
    required this.date,
    required this.idLieu,
    required this.idUtilisateur,
    this.isValidated = false,
    this.moderationStatus = 'pending',
  });

  /// Creates a new review with the current date.
  factory Avis.create({
    required double note,
    required String commentaire,
    required String idLieu,
    required String idUtilisateur,
  }) {
    return Avis(
      note: note,
      commentaire: commentaire,
      date: DateTime.now(),
      idLieu: idLieu,
      idUtilisateur: idUtilisateur,
      isValidated: false,
      moderationStatus: 'pending',
    );
  }

  /// Creates a review from a Supabase row.
  factory Avis.fromMap(Map<String, dynamic> map) {
    return Avis(
      idAvis: SupabaseDataConverter.toInt(map['id_avis'] ?? map['idAvis']),
      note: SupabaseDataConverter.toDouble(map['note']),
      commentaire: SupabaseDataConverter.toStringValue(map['commentaire']),
      date: SupabaseDataConverter.toDateTime(
        map['created_at'] ?? map['date'] ?? map['createdAt'],
      ),
      idLieu: SupabaseDataConverter.toStringValue(
        map['id_lieu'] ?? map['idLieu'],
      ),
      idUtilisateur: SupabaseDataConverter.toStringValue(
        map['id_utilisateur'] ?? map['idUtilisateur'],
      ),
      isValidated: SupabaseDataConverter.toBool(
        map['is_validated'] ?? map['isValidated'],
      ),
      moderationStatus: SupabaseDataConverter.toStringValue(
        map['moderation_status'] ?? map['moderationStatus'] ?? 'pending',
      ),
    );
  }

  /// Converts this review to a Supabase row.
  ///
  /// The identity column `id_avis` is omitted when unset (`0`) so Postgres can
  /// generate it on insert.
  Map<String, dynamic> toMap() {
    return {
      if (idAvis != 0) 'id_avis': idAvis,
      'note': note,
      'commentaire': commentaire,
      'created_at': date.toIso8601String(),
      'id_lieu': idLieu,
      'id_utilisateur': idUtilisateur,
      'is_validated': isValidated,
      'moderation_status': moderationStatus,
    };
  }
}
