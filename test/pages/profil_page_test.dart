import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/data/models/lieu.dart';
import 'package:le_repere/data/models/user_role.dart';
import 'package:le_repere/data/models/utilisateur.dart';
import 'package:le_repere/data/sources/auth_source.dart';
import 'package:le_repere/data/sources/favoris_source.dart';
import 'package:le_repere/data/sources/role_source.dart';
import 'package:le_repere/pages/profil_page.dart';

import '../support/fake_auth_source.dart';
import '../support/fake_favoris_source.dart';
import '../support/fake_role_source.dart';
import '../support/fake_utilisateur_source.dart';

void main() {
  const utilisateur = Utilisateur(
    id: 'user-id',
    nom: 'Jules Baron',
    email: 'jules.baron@uphf.fr',
    positionGps: 'Valenciennes',
  );

  testWidgets('shows current user data', (tester) async {
    await tester.pumpWidget(_buildPage(Stream.value(utilisateur)));
    await tester.pump();

    expect(find.text('Jules Baron'), findsOneWidget);
    expect(find.text('jules.baron@uphf.fr'), findsOneWidget);
    expect(find.text('Valenciennes'), findsOneWidget);
  });

  testWidgets('shows favorite places', (tester) async {
    const favoritePlace = Lieu(
      id: 'place-id',
      nom: 'BU Sciences',
      description: 'Bibliotheque universitaire',
      categorie: LieuCategorie.bibliotheque,
    );

    await tester.pumpWidget(
      _buildPage(
        Stream.value(utilisateur),
        favorisSource: FakeFavorisSource(
          placesStream: Stream.value(const [favoritePlace]),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Mes favoris'), findsOneWidget);
    expect(find.text('BU Sciences'), findsOneWidget);
  });

  testWidgets('removes a favorite place from profile carousel', (tester) async {
    const favoritePlace = Lieu(
      id: 'place-id',
      nom: 'BU Sciences',
      description: 'Bibliotheque universitaire',
      categorie: LieuCategorie.bibliotheque,
    );
    final favorisSource = FakeFavorisSource(
      placesStream: Stream.value(const [favoritePlace]),
    );

    await tester.pumpWidget(
      _buildPage(Stream.value(utilisateur), favorisSource: favorisSource),
    );
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byTooltip('Retirer des favoris'));
    await tester.pump();

    expect(favorisSource.updates, [(lieuId: 'place-id', isFavorite: false)]);
  });

  testWidgets('hides empty GPS position', (tester) async {
    await tester.pumpWidget(
      _buildPage(
        Stream.value(
          const Utilisateur(
            id: 'user-id',
            nom: 'Jules Baron',
            email: 'jules.baron@uphf.fr',
            positionGps: '',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Valenciennes'), findsNothing);
  });

  testWidgets('shows loading state', (tester) async {
    final controller = StreamController<Utilisateur?>();
    addTearDown(controller.close);

    await tester.pumpWidget(_buildPage(controller.stream));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows missing profile state', (tester) async {
    await tester.pumpWidget(_buildPage(Stream.value(null)));
    await tester.pump();

    expect(find.text('Profil introuvable'), findsOneWidget);
  });

  testWidgets('shows profile loading error', (tester) async {
    await tester.pumpWidget(
      _buildPage(Stream<Utilisateur?>.error(Exception('failure'))),
    );
    await tester.pump();

    expect(find.text('Erreur de chargement du profil'), findsOneWidget);
  });

  testWidgets('tapping Déconnexion signs out', (tester) async {
    final auth = FakeAuthSource();
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      _buildPage(Stream.value(utilisateur), authSource: auth),
    );
    await tester.pump();
    await tester.tap(find.text('Déconnexion'));
    await tester.pump();

    expect(auth.signOutCount, 1);
  });

  testWidgets('hides moderation tools for standard users', (tester) async {
    final role = FakeRoleSource(role: UserRole.utilisateur);
    addTearDown(role.dispose);

    await tester.pumpWidget(
      _buildPage(Stream.value(utilisateur), roleSource: role),
    );
    await tester.pump();

    expect(find.text('Valider les propositions'), findsNothing);
  });

  testWidgets('shows moderation tools for moderators', (tester) async {
    final role = FakeRoleSource(role: UserRole.moderateur);
    addTearDown(role.dispose);

    await tester.pumpWidget(
      _buildPage(Stream.value(utilisateur), roleSource: role),
    );
    await tester.pump();

    expect(find.text('Valider les propositions'), findsOneWidget);
  });
}

Widget _buildPage(
  Stream<Utilisateur?> stream, {
  AuthSource? authSource,
  RoleSource? roleSource,
  FavorisSource? favorisSource,
}) {
  return MaterialApp(
    home: ProfilPage(
      authSource: authSource ?? FakeAuthSource(),
      utilisateurSource: FakeUtilisateurSource(stream),
      roleSource: roleSource ?? FakeRoleSource(),
      favorisSource: favorisSource ?? FakeFavorisSource(),
    ),
  );
}
