import '../../core/utils/firestore_data_converter.dart';

/// Place review ready for Firestore reads and writes.
class Avis {
  final int idAvis;
  final int note;
  final String commentaire;
  final DateTime date;
  final int idLieu;
  final String idUtilisateur;

  /// Creates a place review.
  const Avis({
    this.idAvis = 0,
    required this.note,
    required this.commentaire,
    required this.date,
    required this.idLieu,
    required this.idUtilisateur,
  });

  /// Creates a new review with the current date.
  factory Avis.create({
    required int note,
    required String commentaire,
    required int idLieu,
    required String idUtilisateur,
  }) {
    return Avis(
      note: note,
      commentaire: commentaire,
      date: DateTime.now(),
      idLieu: idLieu,
      idUtilisateur: idUtilisateur,
    );
  }

  /// Creates a review from Firestore data.
  factory Avis.fromMap(Map<String, dynamic> map) {
    return Avis(
      idAvis: FirestoreDataConverter.toInt(map['idAvis']),
      note: FirestoreDataConverter.toInt(map['note']),
      commentaire: FirestoreDataConverter.toStringValue(map['commentaire']),
      date: FirestoreDataConverter.toDateTime(map['date'] ?? map['createdAt']),
      idLieu: FirestoreDataConverter.toInt(map['idLieu']),
      idUtilisateur: FirestoreDataConverter.toStringValue(map['idUtilisateur']),
    );
  }

  /// Converts this review to Firestore data.
  Map<String, dynamic> toMap() {
    return {
      'idAvis': idAvis,
      'note': note,
      'commentaire': commentaire,
      'createdAt': date,
      'idLieu': idLieu,
      'idUtilisateur': idUtilisateur,
    };
  }
}
