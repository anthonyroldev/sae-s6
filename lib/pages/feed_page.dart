import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import 'feed/home_header.dart';
import 'feed/lieu.dart';
import 'feed/place_card.dart';
import 'feed/search_header_delegate.dart';

/// Home feed showing available campus places.
class FeedPage extends StatefulWidget {
  static const _filters = [
    'Pour vous',
    'Repas',
    'Bibliothèque',
    'Assos',
    'Services',
    'À proximité',
  ];

  static const _places = [
    Lieu(
      nom: 'Cafétéria INSA',
      description: 'Le restaurant universitaire du campus',
      categorie: 'Repas',
      heures: '11h30 - 14h00',
      icon: Icons.restaurant,
      imageUrl: '',
      isOpen: true,
    ),
    Lieu(
      nom: 'BU Sciences',
      description: 'Bibliothèque universitaire, accès WiFi',
      categorie: 'Bibliothèque',
      heures: '8h00 - 20h00',
      icon: Icons.menu_book,
      imageUrl: '',
      isOpen: true,
    ),
    Lieu(
      nom: 'BDE INSA',
      description: 'Bureau des étudiants, salle des assos',
      categorie: 'Associations',
      heures: '14h00 - 18h00',
      icon: Icons.groups,
      imageUrl: '',
      isOpen: false,
    ),
    Lieu(
      nom: 'Le Kfet',
      description: 'Petite restauration rapide, snacks, café',
      categorie: 'Restauration',
      heures: '8h00 - 16h00',
      icon: Icons.local_cafe,
      imageUrl: '',
      isOpen: true,
    ),
  ];

  /// Creates the home feed page.
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
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
        child: ValueListenableBuilder<String>(
          valueListenable: _searchQuery,
          builder: (context, query, _) {
            final places = FeedPage._places
                .where((place) => _matchesSearch(place, query))
                .toList(growable: false);

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
                if (places.isEmpty)
                  const SliverFillRemaining(
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
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.lg,
                    ),
                    sliver: SliverList.separated(
                      itemCount: places.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) =>
                          PlaceCard(place: places[index]),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _matchesSearch(Lieu place, String query) {
    final search = query.trim().toLowerCase();
    if (search.isEmpty) {
      return true;
    }

    return place.nom.toLowerCase().contains(search);
  }
}
