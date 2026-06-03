import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/utils/logger.dart';
import '../data/models/avis_with_auteur.dart';
import '../data/models/lieu.dart';
import '../data/sources/avis_supabase_source.dart';
import '../data/sources/favoris_supabase_source.dart';
import 'avis_list_page.dart';
import 'feed/category_badge.dart';
import 'feed/place_category_icon.dart';
import 'feed/status_badge.dart';
import 'lieu/avis_card.dart';

/// Full detail page for a campus place.
class LieuDetailPage extends StatefulWidget {
  final Lieu lieu;

  const LieuDetailPage({super.key, required this.lieu});

  @override
  State<LieuDetailPage> createState() => _LieuDetailPageState();
}

class _LieuDetailPageState extends State<LieuDetailPage> {
  final _avisSource = AvisSupabaseSource();
  final _favorisSource = FavorisSupabaseSource();
  late final Future<_AvisData> _avisFuture;

  @override
  void initState() {
    super.initState();
    _avisFuture = _loadAvisData();
  }

  Future<_AvisData> _loadAvisData() async {
    final results = await Future.wait([
      _avisSource.fetchForLieu(widget.lieu.id, limit: 3),
      _avisSource.fetchStats(widget.lieu.id),
    ]);
    return _AvisData(
      preview: results[0] as List<AvisWithAuteur>,
      stats: results[1] as ({double average, int count}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x55000000),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
        body: StreamBuilder<Set<String>>(
          stream: _favorisSource.watchCurrentUserPlaceIds(),
          initialData: const <String>{},
          builder: (context, favSnapshot) {
            final isFavorite =
                (favSnapshot.data ?? const <String>{}).contains(widget.lieu.id);
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroImage(),
                  _buildContent(context, isFavorite),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            widget.lieu.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => ColoredBox(
              color: AppColors.surfaceVariant,
              child: Center(
                child: Icon(
                  iconForCategory(widget.lieu.categorie),
                  color: AppColors.secondaryText,
                  size: 64,
                ),
              ),
            ),
          ),
          // Gradient behind back button
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment(0, 0.5),
                colors: [Color(0x88000000), Colors.transparent],
              ),
            ),
          ),
          // Status badge on image
          Positioned(
            top: 56,
            right: AppSpacing.md,
            child: StatusBadge(isOpen: widget.lieu.isOpen),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isFavorite) {
    final lieu = widget.lieu;
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + favorite button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  lieu.nom,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),
              IconButton(
                tooltip: isFavorite
                    ? 'Retirer des favoris'
                    : 'Ajouter aux favoris',
                onPressed: () => _toggleFavorite(context, isFavorite),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? AppColors.errorText
                      : AppColors.secondaryText,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // Category chip
          CategoryBadge(place: lieu),
          const SizedBox(height: AppSpacing.md),
          // Description
          Text(
            lieu.description,
            style: const TextStyle(
              color: Color(0xFF45464D),
              fontSize: 15,
              height: 1.6,
            ),
          ),
          // Horaires section
          if (lieu.heureOuverture != null || lieu.heureFermeture != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildHorairesSection(lieu),
          ],
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.borderSubtle),
          const SizedBox(height: AppSpacing.md),
          // Avis section
          _buildAvisSection(context),
        ],
      ),
    );
  }

  Widget _buildHorairesSection(Lieu lieu) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horaires',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              _HorairesRow(
                jours: 'Lundi — Vendredi',
                heures: lieu.heures.isNotEmpty ? lieu.heures : null,
                isOpen: lieu.isOpen,
              ),
              const Divider(height: 1, color: AppColors.borderSubtle),
              _HorairesRow(
                jours: 'Samedi — Dimanche',
                heures: null,
                isOpen: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvisSection(BuildContext context) {
    return FutureBuilder<_AvisData>(
      future: _avisFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final isLoading =
            snapshot.connectionState == ConnectionState.waiting;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header with average rating
            Row(
              children: [
                const Text(
                  'Avis',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                if (data != null && data.stats.count > 0) ...[
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 2),
                  Text(
                    data.stats.average.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${data.stats.count} avis)',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Preview reviews
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (data == null || data.preview.isEmpty)
              const Text(
                'Aucun avis pour le moment.',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                  height: 1.4,
                ),
              )
            else
              Column(
                children: [
                  for (var i = 0; i < data.preview.length; i++) ...[
                    AvisCard(item: data.preview[i]),
                    if (i < data.preview.length - 1)
                      const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ),
            const SizedBox(height: AppSpacing.md),
            // Voir tous les avis
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AvisListPage(lieu: widget.lieu),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.borderSubtle),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm + 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Voir tous les avis',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Ajouter mon avis
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bientôt disponible !')),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm + 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ajouter mon avis',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleFavorite(BuildContext context, bool isFavorite) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _favorisSource.setFavorite(
        lieuId: widget.lieu.id,
        isFavorite: !isFavorite,
      );
    } on Object catch (error, stackTrace) {
      logger.e(
        'Failed to update favorite place.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Impossible de modifier les favoris.')),
      );
    }
  }
}

class _HorairesRow extends StatelessWidget {
  final String jours;
  final String? heures;
  final bool isOpen;

  const _HorairesRow({
    required this.jours,
    required this.heures,
    required this.isOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          Text(
            jours,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (heures != null)
            Text(
              heures!,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14,
              ),
            )
          else
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.errorBackground,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                child: Text(
                  'Fermé',
                  style: TextStyle(
                    color: AppColors.errorText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AvisData {
  final List<AvisWithAuteur> preview;
  final ({double average, int count}) stats;

  const _AvisData({required this.preview, required this.stats});
}
