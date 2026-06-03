import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../data/models/lieu.dart';
import '../data/models/user_role.dart';
import '../data/models/utilisateur.dart';
import '../data/sources/auth_source.dart';
import '../data/sources/auth_supabase_source.dart';
import '../data/sources/favoris_source.dart';
import '../data/sources/favoris_supabase_source.dart';
import '../data/sources/role_source.dart';
import '../data/sources/role_supabase_source.dart';
import '../data/sources/utilisateur_source.dart';
import '../data/sources/utilisateur_supabase_source.dart';
import 'admin/moderation_propositions_page.dart';
import 'feed/place_card.dart';
import 'profil/profile_header.dart';

/// Profile screen backed by the authenticated Supabase user.
class ProfilPage extends StatelessWidget {
  /// Auth backend injected for testing.
  final AuthSource authSource;

  /// User profile backend injected for testing.
  final UtilisateurSource utilisateurSource;

  /// Favorite places backend injected for testing.
  final FavorisSource favorisSource;

  /// Role backend, used to reveal moderation tools.
  final RoleSource roleSource;

  /// Creates the profile page.
  ProfilPage({
    super.key,
    AuthSource? authSource,
    UtilisateurSource? utilisateurSource,
    RoleSource? roleSource,
    FavorisSource? favorisSource,
  }) : authSource = authSource ?? AuthSupabaseSource(),
       utilisateurSource = utilisateurSource ?? UtilisateurSupabaseSource(),
       favorisSource = favorisSource ?? FavorisSupabaseSource(),
       roleSource = roleSource ?? RoleSupabaseSource();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<Utilisateur?>(
          stream: utilisateurSource.watchCurrent(),
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildContent(snapshot)),
                  _ModerationButton(roleSource: roleSource),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: authSource.signOut,
                      child: const Text('Déconnexion'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(AsyncSnapshot<Utilisateur?> snapshot) {
    if (snapshot.hasError) {
      return const Center(child: Text('Erreur de chargement du profil'));
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    final utilisateur = snapshot.data;
    if (utilisateur == null) {
      return const Center(child: Text('Profil introuvable'));
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileHeader(
            name: utilisateur.nom,
            email: utilisateur.email,
            positionGps: utilisateur.positionGps,
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Mes favoris',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _FavoritePlacesList(favorisSource: favorisSource),
        ],
      ),
    );
  }
}

class _FavoritePlacesList extends StatelessWidget {
  final FavorisSource favorisSource;

  const _FavoritePlacesList({required this.favorisSource});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Lieu>>(
      stream: favorisSource.watchCurrentUserPlaces(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Erreur de chargement des favoris',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 16,
              height: 1.4,
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final places = snapshot.data ?? const <Lieu>[];
        if (places.isEmpty) {
          return const Text(
            'Aucun favori pour le moment.',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 16,
              height: 1.4,
            ),
          );
        }

        return Column(
          children: [
            for (var index = 0; index < places.length; index++) ...[
              PlaceCard(place: places[index]),
              if (index < places.length - 1)
                const SizedBox(height: AppSpacing.md),
            ],
          ],
        );
      },
    );
  }
}

/// Moderation entry point, shown only to moderators and administrators.
class _ModerationButton extends StatelessWidget {
  final RoleSource roleSource;

  const _ModerationButton({required this.roleSource});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserRole>(
      initialData: roleSource.currentRole,
      stream: roleSource.roleChanges,
      builder: (context, snapshot) {
        final role = snapshot.data ?? UserRole.utilisateur;
        if (!role.canModerate) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ModerationPropositionsPage(),
                ),
              ),
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Valider les propositions'),
            ),
          ),
        );
      },
    );
  }
}
