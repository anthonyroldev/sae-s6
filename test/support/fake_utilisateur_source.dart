import 'package:le_repere/data/models/utilisateur.dart';
import 'package:le_repere/data/sources/utilisateur_source.dart';

/// In-memory [UtilisateurSource] for widget tests.
class FakeUtilisateurSource implements UtilisateurSource {
  /// Stream returned by [watchCurrent].
  final Stream<Utilisateur?> stream;

  /// Creates a fake user profile source.
  FakeUtilisateurSource(this.stream);

  @override
  Stream<Utilisateur?> watchCurrent() => stream;
}
