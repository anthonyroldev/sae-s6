import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import 'profil/favorite_place.dart';
import 'profil/favorite_place_card.dart';
import 'profil/profile_header.dart';
import 'profil/profile_review.dart';
import 'profil/profile_section.dart';
import 'profil/review_card.dart';
import 'profil/settings_card.dart';

/// Profile screen with user details, favorite places, reviews, and settings.
class ProfilPage extends StatelessWidget {
  static const _favoritePlaces = [
    FavoritePlace(
      name: 'Le K-Fet',
      subtitle: 'Campus INSA',
      category: 'Cafe',
      icon: Icons.local_cafe,
    ),
    FavoritePlace(
      name: 'Bibliotheque Marie Curie',
      subtitle: 'Campus INSA',
      category: 'Etude',
      icon: Icons.menu_book,
    ),
    FavoritePlace(
      name: 'Gymnase C',
      subtitle: 'Campus INSA',
      category: 'Sport',
      icon: Icons.sports_basketball,
    ),
  ];

  static const _reviews = [
    ProfileReview(
      placeName: 'Le K-Fet',
      date: 'il y a 2 jours',
      rating: 4,
      comment:
          "Tres bon endroit pour se detendre entre les cours. Le cafe est correct et l'ambiance est toujours sympa.",
    ),
    ProfileReview(
      placeName: 'Restaurant Universitaire',
      date: 'il y a 1 semaine',
      rating: 4,
      comment:
          'Pratique et rapide. Les plats vegetariens se sont beaucoup ameliores cette annee.',
    ),
  ];

  /// Creates the profile page.
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const ProfileHeader(),
                    const SizedBox(height: AppSpacing.lg),
                    ProfileSection(
                      title: 'Favoris',
                      child: SizedBox(
                        height: 214,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _favoritePlaces.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: AppSpacing.md),
                          itemBuilder: (context, index) => FavoritePlaceCard(
                            place: _favoritePlaces[index],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ProfileSection(
                      title: 'Mes Avis',
                      child: Column(
                        children: _reviews
                            .map(
                              (review) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: ReviewCard(review: review),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const ProfileSection(
                      title: 'Paramètres',
                      child: SettingsCard(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
