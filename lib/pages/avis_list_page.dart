import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../data/models/avis_with_auteur.dart';
import '../data/models/lieu.dart';
import '../data/sources/avis_supabase_source.dart';
import 'add_avis_page.dart';
import 'lieu/avis_card.dart';

class AvisListPage extends StatefulWidget {
  final Lieu lieu;

  const AvisListPage({super.key, required this.lieu});

  @override
  State<AvisListPage> createState() => _AvisListPageState();
}

class _AvisListPageState extends State<AvisListPage> {
  final _avisSource = AvisSupabaseSource();
  late Future<_AvisListData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_AvisListData> _loadData() async {
    final results = await Future.wait([
      _avisSource.fetchForLieu(widget.lieu.id),
      _avisSource.fetchStats(widget.lieu.id),
    ]);
    return _AvisListData(
      avisList: results[0] as List<AvisWithAuteur>,
      stats: results[1] as ({double average, int count}),
    );
  }

  void _openAddAvis() {
    Navigator.of(context)
        .push<bool>(
          MaterialPageRoute(builder: (_) => AddAvisPage(lieu: widget.lieu)),
        )
        .then((added) {
      if (added == true) {
        setState(() => _dataFuture = _loadData());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.lieu.nom,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: FutureBuilder<_AvisListData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Erreur de chargement des avis',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 16),
              ),
            );
          }
          final data = snapshot.data!;
          return Column(
            children: [
              if (data.stats.count > 0) _StatsHeader(stats: data.stats),
              Expanded(
                child: data.avisList.isEmpty
                    ? _EmptyState(onAdd: _openAddAvis)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md + 80,
                        ),
                        itemCount: data.avisList.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (_, index) =>
                            AvisCard(item: data.avisList[index]),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddAvis,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text(
          'Mon avis',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  final ({double average, int count}) stats;

  const _StatsHeader({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 22),
          const SizedBox(width: AppSpacing.xs),
          Text(
            stats.average.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '(${stats.count} avis)',
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.rate_review_outlined,
              size: 56,
              color: AppColors.borderSubtle,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Aucun avis pour le moment.',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Soyez le premier à partager votre expérience !',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm + 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ajouter un avis',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvisListData {
  final List<AvisWithAuteur> avisList;
  final ({double average, int count}) stats;

  const _AvisListData({required this.avisList, required this.stats});
}
