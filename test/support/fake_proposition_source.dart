import 'dart:async';

import 'package:le_repere/data/models/proposition_lieu.dart';
import 'package:le_repere/data/sources/proposition_source.dart';

/// In-memory [PropositionSource] for widget tests.
class FakePropositionSource implements PropositionSource {
  /// Proposals submitted through [soumettre], in order.
  final List<PropositionLieu> submitted = [];

  /// Proposal ids validated through [valider], in order.
  final List<int> validated = [];

  /// Proposal ids rejected through [refuser], in order.
  final List<int> rejected = [];

  final StreamController<List<PropositionLieu>> _controller =
      StreamController<List<PropositionLieu>>.broadcast();

  @override
  Future<void> soumettre(PropositionLieu proposition) async {
    submitted.add(proposition);
  }

  @override
  Stream<List<PropositionLieu>> watchEnAttente() => _controller.stream;

  @override
  Future<void> valider(int id) async {
    validated.add(id);
  }

  @override
  Future<void> refuser(int id) async {
    rejected.add(id);
  }

  /// Emits the pending list on [watchEnAttente].
  void emit(List<PropositionLieu> propositions) =>
      _controller.add(propositions);

  /// Closes the internal stream controller.
  void dispose() => _controller.close();
}
