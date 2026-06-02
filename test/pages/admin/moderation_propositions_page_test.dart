import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/data/models/proposition_lieu.dart';
import 'package:le_repere/data/models/user_role.dart';
import 'package:le_repere/pages/admin/moderation_propositions_page.dart';

import '../../support/fake_proposition_source.dart';
import '../../support/fake_role_source.dart';

PropositionLieu _proposition({int id = 1, String nom = 'Foyer'}) {
  return PropositionLieu(id: id, nom: nom, description: 'desc');
}

Widget _page(FakePropositionSource propositions, FakeRoleSource role) {
  return MaterialApp(
    home: ModerationPropositionsPage(
      propositionSource: propositions,
      roleSource: role,
    ),
  );
}

void main() {
  testWidgets('denies access to non-moderators', (tester) async {
    final propositions = FakePropositionSource();
    final role = FakeRoleSource(role: UserRole.utilisateur);
    addTearDown(propositions.dispose);
    addTearDown(role.dispose);

    await tester.pumpWidget(_page(propositions, role));
    await tester.pump();

    expect(find.text('Accès réservé aux modérateurs.'), findsOneWidget);
  });

  testWidgets('lists pending proposals for a moderator', (tester) async {
    final propositions = FakePropositionSource();
    final role = FakeRoleSource(role: UserRole.moderateur);
    addTearDown(propositions.dispose);
    addTearDown(role.dispose);

    await tester.pumpWidget(_page(propositions, role));
    propositions.emit([_proposition(nom: 'Foyer Etudiant')]);
    await tester.pump();

    expect(find.text('Foyer Etudiant'), findsOneWidget);
    expect(find.text('Valider'), findsOneWidget);
  });

  testWidgets('validating calls the source', (tester) async {
    final propositions = FakePropositionSource();
    final role = FakeRoleSource(role: UserRole.admin);
    addTearDown(propositions.dispose);
    addTearDown(role.dispose);

    await tester.pumpWidget(_page(propositions, role));
    propositions.emit([_proposition(id: 42)]);
    await tester.pump();

    await tester.tap(find.text('Valider'));
    await tester.pump();

    expect(propositions.validated, [42]);
  });

  testWidgets('rejecting calls the source', (tester) async {
    final propositions = FakePropositionSource();
    final role = FakeRoleSource(role: UserRole.admin);
    addTearDown(propositions.dispose);
    addTearDown(role.dispose);

    await tester.pumpWidget(_page(propositions, role));
    propositions.emit([_proposition(id: 7)]);
    await tester.pump();

    await tester.tap(find.text('Refuser'));
    await tester.pump();

    expect(propositions.rejected, [7]);
  });
}
