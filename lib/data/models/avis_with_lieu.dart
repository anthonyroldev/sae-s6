import 'avis.dart';

/// Review enriched with the place's display name.
class AvisWithLieu {
  final Avis avis;
  final String nomLieu;

  const AvisWithLieu({required this.avis, required this.nomLieu});
}
