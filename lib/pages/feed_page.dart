import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/utils/logger.dart';
import '../data/models/lieu.dart';
import '../data/sources/favoris_source.dart';
import '../data/sources/favoris_supabase_source.dart';
import '../data/sources/lieu_supabase_source.dart';
import 'add_lieu_page.dart';
import 'feed/home_header.dart';
import 'feed/place_card.dart';
import 'feed/search_header_delegate.dart';
import 'lieu_detail_page.dart';

class FeedPage extends StatefulWidget {
  static const _filters = LieuCategorie.values;

  /// Creates the home feed page.
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _lieuSource = LieuSupabaseSource();
  final _favorisSource = FavorisSupabaseSource();
  final _searchController = TextEditingController();
  final _searchQuery = ValueNotifier<String>('');
  final _selectedCategory = ValueNotifier<LieuCategorie>(LieuCategorie.all);

  @override
  void dispose() {
    _searchController.dispose();
    _searchQuery.dispose();
    _selectedCategory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddLieuPage,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        tooltip: 'Ajouter un lieu',
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<Lieu>>(
          stream: _lieuSource.watchAll(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              logger.e(
                'Failed to load feed places.',
                error: snapshot.error,
                stackTrace: snapshot.stackTrace,
              );
            }

            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: HomeHeader()),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: SearchHeaderDelegate(
                    filters: FeedPage._filters,
                    selectedFilter: _selectedCategory.value,
                    searchController: _searchController,
                    onSearchChanged: (value) => _searchQuery.value = value,
                    onFilterSelected: (value) {
                      setState(() => _selectedCategory.value = value);
                    },
                  ),
                ),
                ..._buildContentSlivers(snapshot, _favorisSource),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildContentSlivers(
    AsyncSnapshot<List<Lieu>> snapshot,
    FavorisSource favorisSource,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (snapshot.hasError) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              'Erreur de chargement des lieux',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ),
      ];
    }

    final places = snapshot.data ?? const <Lieu>[];
    return [
      StreamBuilder<Set<String>>(
        stream: favorisSource.watchCurrentUserPlaceIds(),
        initialData: const <String>{},
        builder: (context, favoritesSnapshot) {
          final favoriteIds = favoritesSnapshot.data ?? const <String>{};

          return ValueListenableBuilder<String>(
            valueListenable: _searchQuery,
            builder: (context, query, _) {
              final filteredPlaces = places
                  .where(
                    (place) =>
                        _matchesSearch(place, query) &&
                        _matchesFilter(place, _selectedCategory.value),
                  )
                  .toList(growable: false);

              if (filteredPlaces.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'Aucun lieu trouve',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                sliver: SliverList.separated(
                  itemCount: filteredPlaces.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final place = filteredPlaces[index];
                    final isFavorite = favoriteIds.contains(place.id);

                    return PlaceCard(
                      place: place,
                      isFavorite: isFavorite,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => LieuDetailPage(lieu: place),
                        ),
                      ),
                      onFavoritePressed: () {
                        _setFavorite(
                          favorisSource: favorisSource,
                          place: place,
                          isFavorite: !isFavorite,
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    ];
  }

  bool _matchesSearch(Lieu place, String query) {
    final search = query.trim().toLowerCase();
    if (search.isEmpty) {
      return true;
    }

    return place.nom.toLowerCase().contains(search);
  }

  bool _matchesFilter(Lieu place, LieuCategorie filter) {
    return filter == LieuCategorie.all || place.categorie == filter;
  }

  void _openAddLieuPage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => AddLieuPage()));
  }

  Future<void> _setFavorite({
    required FavorisSource favorisSource,
    required Lieu place,
    required bool isFavorite,
  }) async {
    try {
      await favorisSource.setFavorite(lieuId: place.id, isFavorite: isFavorite);
    } on Object catch (error, stackTrace) {
      logger.e(
        'Failed to update favorite place.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de modifier les favoris.')),
      );
    }
  }
}
