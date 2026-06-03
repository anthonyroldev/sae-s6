import '../models/proposition_lieu.dart';

/// Place-proposal backend contract.
///
/// Keeps Supabase types out of the UI so screens can be tested with a fake.
abstract interface class PropositionSource {
  /// Submits a new place proposal for the current user.
  Future<void> soumettre(PropositionLieu proposition);

  /// Watches the proposals still awaiting moderation, oldest first.
  Stream<List<PropositionLieu>> watchEnAttente();

  /// Validates the proposal [id]: publishes the place and marks it validated.
  Future<void> valider(int id);

  /// Rejects the proposal [id].
  Future<void> refuser(int id);
}
