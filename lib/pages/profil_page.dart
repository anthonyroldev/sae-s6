import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../data/models/lieu.dart';
import '../data/models/utilisateur.dart';
import '../data/sources/auth_source.dart';
import '../data/sources/auth_supabase_source.dart';
import '../data/sources/favoris_source.dart';
import '../data/sources/favoris_supabase_source.dart';
import '../data/sources/utilisateur_source.dart';
import '../data/sources/utilisateur_supabase_source.dart';
import '../core/utils/logger.dart';
import 'feed/place_category_icon.dart';
import 'profil/profile_header.dart';

/// Profile screen backed by the authenticated Supabase user.
class ProfilPage extends StatelessWidget {
  /// Auth backend injected for testing.
  final AuthSource authSource;

  /// User profile backend injected for testing.
  final UtilisateurSource utilisateurSource;

  /// Favorite places backend injected for testing.
  final FavorisSource favorisSource;

  /// Creates the profile page.
  ProfilPage({
    super.key,
    AuthSource? authSource,
    UtilisateurSource? utilisateurSource,
    FavorisSource? favorisSource,
  }) : authSource = authSource ?? AuthSupabaseSource(),
       utilisateurSource = utilisateurSource ?? UtilisateurSupabaseSource(),
       favorisSource = favorisSource ?? FavorisSupabaseSource();

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
          return const _FavoritesSection(
            count: 0,
            child: _EmptyFavoritesMessage(),
          );
        }

        return _FavoritesSection(
          count: places.length,
          child: SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: places.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final place = places[index];
                return _FavoritePlaceCard(
                  place: place,
                  onRemoveFavorite: () => _removeFavorite(context, place),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _removeFavorite(BuildContext context, Lieu place) async {
    if (place.id.isEmpty) {
      logger.w('Cannot remove favorite without place id.');
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    try {
      await favorisSource.setFavorite(lieuId: place.id, isFavorite: false);
      if (!context.mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text('${place.nom} retire des favoris.')),
      );
    } on Object catch (error, stackTrace) {
      logger.e(
        'Failed to remove favorite place: ${place.id}.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!context.mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Impossible de retirer ce favori.')),
      );
    }
  }
}

class _FavoritesSection extends StatelessWidget {
  final int count;
  final Widget child;

  const _FavoritesSection({required this.count, required this.child});

  @override
  Widget build(BuildContext context) {
    final countLabel = count <= 1 ? '$count lieu' : '$count lieux';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Text(
                'Mes favoris',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.selected,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Text(
                  countLabel,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Glissez horizontalement pour retrouver vos lieux enregistres.',
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }
}

class _EmptyFavoritesMessage extends StatelessWidget {
  const _EmptyFavoritesMessage();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(Icons.favorite_border, color: AppColors.secondaryText),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Aucun favori pour le moment.',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritePlaceCard extends StatelessWidget {
  final Lieu place;
  final VoidCallback onRemoveFavorite;

  const _FavoritePlaceCard({
    required this.place,
    required this.onRemoveFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 118,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      place.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: AppColors.surfaceVariant,
                        child: Icon(
                          iconForCategory(place.categorie),
                          color: AppColors.secondaryText,
                          size: 42,
                        ),
                      ),
                    ),
                    Positioned(
                      top: AppSpacing.xs,
                      right: AppSpacing.xs,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: onRemoveFavorite,
                          tooltip: 'Retirer des favoris',
                          icon: const Icon(
                            Icons.favorite,
                            color: AppColors.errorText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.nom,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        place.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            iconForCategory(place.categorie),
                            color: AppColors.accent,
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              place.categorie.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
