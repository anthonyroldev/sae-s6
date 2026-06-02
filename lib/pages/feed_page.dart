import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/utils/app_logger.dart';
import '../data/models/lieu.dart';
import '../data/sources/lieu_supabase_source.dart';
import 'add_lieu_page.dart';
import 'feed/home_header.dart';
import 'feed/place_card.dart';
import 'feed/search_header_delegate.dart';

class FeedPage extends StatefulWidget {
  static const _filters = LieuCategorie.values;

  /// Creates the home feed page.
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _lieuSource = LieuSupabaseSource();
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
              AppLogger.error(
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
                ..._buildContentSlivers(snapshot),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildContentSlivers(AsyncSnapshot<List<Lieu>> snapshot) {
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
      ValueListenableBuilder<String>(
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
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) =>
                  PlaceCard(place: filteredPlaces[index]),
            ),
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
    ).push(MaterialPageRoute<void>(builder: (_) => const AddLieuPage()));
  }
}
