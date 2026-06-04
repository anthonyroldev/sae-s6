import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../data/models/avis_with_lieu.dart';
import '../data/models/lieu.dart';
import '../data/models/user_role.dart';
import '../data/models/utilisateur.dart';
import '../data/sources/avis_supabase_source.dart';
import '../data/sources/auth_source.dart';
import '../data/sources/auth_supabase_source.dart';
import '../data/sources/favoris_source.dart';
import '../data/sources/favoris_supabase_source.dart';
import '../data/sources/role_source.dart';
import '../data/sources/role_supabase_source.dart';
import '../data/sources/utilisateur_source.dart';
import '../data/sources/utilisateur_supabase_source.dart';
import '../core/utils/logger.dart';
import 'feed/place_category_icon.dart';
import 'admin/moderation_propositions_page.dart';
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

  /// Reviews backend injected for testing.
  final AvisSource avisSource;

  /// Creates the profile page.
  ProfilPage({
    super.key,
    AuthSource? authSource,
    UtilisateurSource? utilisateurSource,
    RoleSource? roleSource,
    FavorisSource? favorisSource,
    AvisSource? avisSource,
  }) : authSource = authSource ?? AuthSupabaseSource(),
       utilisateurSource = utilisateurSource ?? UtilisateurSupabaseSource(),
       favorisSource = favorisSource ?? FavorisSupabaseSource(),
       roleSource = roleSource ?? RoleSupabaseSource(),
       avisSource = avisSource ?? AvisSupabaseSource();

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
          _FavoritePlacesList(favorisSource: favorisSource),
          const SizedBox(height: AppSpacing.xl),
          _UserAvisList(avisSource: avisSource),
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

class _UserAvisList extends StatefulWidget {
  final AvisSource avisSource;

  const _UserAvisList({required this.avisSource});

  @override
  State<_UserAvisList> createState() => _UserAvisListState();
}

class _UserAvisListState extends State<_UserAvisList> {
  late final Future<List<AvisWithLieu>> _avisFuture;

  @override
  void initState() {
    super.initState();
    _avisFuture = widget.avisSource.fetchForCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AvisWithLieu>>(
      future: _avisFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final avis = snapshot.data ?? [];
        final countLabel = avis.length <= 1 ? '${avis.length} avis' : '${avis.length} avis';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Text(
                    'Mes avis',
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
              'Vos avis publiées sur Le Repère.',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (avis.isEmpty)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Icon(Icons.rate_review_outlined, color: AppColors.secondaryText),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Aucun avis publié pour le moment.',
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
              )
            else
              Column(
                children: [
                  for (var i = 0; i < avis.length; i++) ...[
                    _UserAvisCard(item: avis[i]),
                    if (i < avis.length - 1)
                      const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ),
          ],
        );
      },
    );
  }
}

class _UserAvisCard extends StatelessWidget {
  final AvisWithLieu item;

  const _UserAvisCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.nomLieu,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _formatDate(item.avis.date),
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < item.avis.note ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.avis.commentaire,
              style: const TextStyle(
                color: Color(0xFF45464D),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

/// Moderation entry point, shown only to administrators.
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
        if (!role.isAdmin) {
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
