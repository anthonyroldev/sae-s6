import '../models/utilisateur.dart';

/// User profile backend contract used by the presentation layer.
abstract interface class UtilisateurSource {
  /// Watches the authenticated user's profile.
  Stream<Utilisateur?> watchCurrent();
}
