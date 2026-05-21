import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../data/models/lieu.dart';
import '../data/sources/lieu_firestore_source.dart';
import 'feed/home_header.dart';
import 'feed/place_card.dart';
import 'feed/search_header_delegate.dart';

/// Home feed showing available campus places.
class FeedPage extends StatefulWidget {
  static const _filters = [
    'Pour vous',
    'Repas',
    'Bibliotheque',
    'Assos',
    'Services',
    'A proximite',
  ];

  /// Creates the home feed page.
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _lieuSource = LieuFirestoreSource();
  final _searchController = TextEditingController();
  final _searchQuery = ValueNotifier<String>('');

  @override
  void dispose() {
    _searchController.dispose();
    _searchQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<Lieu>>(
          stream: _lieuSource.watchAll(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              debugPrint('Feed Firestore error: ${snapshot.error}');
            }

            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: HomeHeader()),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: SearchHeaderDelegate(
                    filters: FeedPage._filters,
                    searchController: _searchController,
                    onSearchChanged: (value) => _searchQuery.value = value,
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
              'Erreur de chargement\n${snapshot.error}',
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
              .where((place) => _matchesSearch(place, query))
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
}
