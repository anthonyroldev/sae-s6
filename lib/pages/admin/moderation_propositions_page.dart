import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/logger.dart';
import '../../data/models/admin_metrics.dart';
import '../../data/models/proposition_lieu.dart';
import '../../data/models/user_role.dart';
import '../../data/sources/admin_metrics_source.dart';
import '../../data/sources/admin_metrics_supabase_source.dart';
import '../../data/sources/proposition_source.dart';
import '../../data/sources/proposition_supabase_source.dart';
import '../../data/sources/role_source.dart';
import '../../data/sources/role_supabase_source.dart';

/// Administrator dashboard with app metrics and pending place proposals.
class ModerationPropositionsPage extends StatefulWidget {
  /// Proposal backend.
  final PropositionSource propositionSource;

  /// Role backend, used to guard access.
  final RoleSource roleSource;

  /// Metrics backend, used to build the administrator dashboard.
  final AdminMetricsSource metricsSource;

  /// Creates the administrator dashboard page.
  ModerationPropositionsPage({
    super.key,
    PropositionSource? propositionSource,
    RoleSource? roleSource,
    AdminMetricsSource? metricsSource,
  }) : propositionSource = propositionSource ?? PropositionSupabaseSource(),
       roleSource = roleSource ?? RoleSupabaseSource(),
       metricsSource = metricsSource ?? AdminMetricsSupabaseSource();

  @override
  State<ModerationPropositionsPage> createState() =>
      _ModerationPropositionsPageState();
}

class _ModerationPropositionsPageState
    extends State<ModerationPropositionsPage> {
  Future<AdminMetrics>? _metricsFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        title: const Text(
          'Modération',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: _refreshMetrics,
            tooltip: 'Actualiser les métriques',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: StreamBuilder<UserRole>(
        initialData: widget.roleSource.currentRole,
        stream: widget.roleSource.roleChanges,
        builder: (context, snapshot) {
          final role = snapshot.data ?? UserRole.utilisateur;
          if (!role.isAdmin) {
            return const _CenteredMessage('Accès réservé aux administrateurs.');
          }
          return _buildDashboard();
        },
      ),
    );
  }

  void _refreshMetrics() {
    setState(() {
      _metricsFuture = widget.metricsSource.fetch();
    });
  }

  Widget _buildDashboard() {
    final metricsFuture = _metricsFuture ??= widget.metricsSource.fetch();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _MetricsPanel(metricsFuture: metricsFuture),
        const SizedBox(height: AppSpacing.xl),
        const _SectionHeader(
          title: 'Propositions en attente',
          subtitle:
              'Validez ou refusez les lieux proposés par les utilisateurs.',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildQueue(),
      ],
    );
  }

  Widget _buildQueue() {
    return StreamBuilder<List<PropositionLieu>>(
      stream: widget.propositionSource.watchEnAttente(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _InlineMessage('Erreur de chargement\n${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final propositions = snapshot.data ?? const <PropositionLieu>[];
        if (propositions.isEmpty) {
          return const _InlineMessage('Aucune proposition en attente.');
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: propositions.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) => _PropositionCard(
            proposition: propositions[index],
            onValidate: () => _validate(propositions[index]),
            onReject: () => _reject(propositions[index]),
          ),
        );
      },
    );
  }

  Future<void> _validate(PropositionLieu proposition) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.propositionSource.valider(proposition.id);
      messenger.showSnackBar(
        SnackBar(content: Text('"${proposition.nom}" publié.')),
      );
      _refreshMetrics();
    } on Object catch (error, stackTrace) {
      logger.e(
        'Failed to validate place proposal: ${proposition.id}.',
        error: error,
        stackTrace: stackTrace,
      );
      messenger.showSnackBar(
        SnackBar(content: Text('Échec de la validation : $error')),
      );
    }
  }

  Future<void> _reject(PropositionLieu proposition) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.propositionSource.refuser(proposition.id);
      messenger.showSnackBar(
        SnackBar(content: Text('"${proposition.nom}" refusé.')),
      );
      _refreshMetrics();
    } on Object catch (error, stackTrace) {
      logger.e(
        'Failed to reject place proposal: ${proposition.id}.',
        error: error,
        stackTrace: stackTrace,
      );
      messenger.showSnackBar(
        SnackBar(content: Text('Échec du refus : $error')),
      );
    }
  }
}

class _MetricsPanel extends StatelessWidget {
  final Future<AdminMetrics> metricsFuture;

  const _MetricsPanel({required this.metricsFuture});

  @override
  Widget build(BuildContext context) {
    return _MetricSurface(
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        title: const Text(
          'Metriques',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: const Text(
          'Vue rapide sur le contenu et les comptes crées.',
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 13,
            height: 1.3,
          ),
        ),
        children: [
          FutureBuilder<AdminMetrics>(
            future: metricsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _InlineMessage(
                  'Impossible de charger les métriques\n${snapshot.error}',
                );
              }
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return _MetricsContent(metrics: snapshot.data!);
            },
          ),
        ],
      ),
    );
  }
}

class _MetricsContent extends StatelessWidget {
  final AdminMetrics metrics;

  const _MetricsContent({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 620;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isWide ? 3 : 2,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: isWide ? 1.35 : 1.05,
              children: [
                _MetricCard(
                  icon: Icons.place_outlined,
                  label: 'Lieux',
                  value: metrics.totalPlaces.toString(),
                  detail: 'Lieux publiés sur la carte',
                ),
                _MetricCard(
                  icon: Icons.star_border,
                  label: 'Avis',
                  value: metrics.totalReviews.toString(),
                  detail: 'Moyenne ${_formatDecimal(metrics.averageReview)}/5',
                ),
                _MetricCard(
                  icon: Icons.rate_review_outlined,
                  label: 'Couverture avis',
                  value: metrics.reviewedPlaces.toString(),
                  detail:
                      '${_formatPercent(metrics.reviewedPlaceRate)} des lieux ont un avis',
                ),
                _MetricCard(
                  icon: Icons.image_outlined,
                  label: 'Photos',
                  value: metrics.placesWithImage.toString(),
                  detail:
                      '${_formatPercent(metrics.imageCoverageRate)} des lieux ont une photo',
                ),
                _MetricCard(
                  icon: Icons.schedule_outlined,
                  label: 'Horaires',
                  value: metrics.placesWithHours.toString(),
                  detail:
                      '${_formatPercent(metrics.hoursCoverageRate)} des lieux renseignes',
                ),
                _MetricCard(
                  icon: Icons.category_outlined,
                  label: 'Catégorie principale',
                  value: metrics.topCategoryLabel,
                  detail:
                      '${metrics.topCategoryCount} lieux dans cette categorie',
                ),
                _MetricCard(
                  icon: Icons.analytics_outlined,
                  label: 'Avis / lieu',
                  value: _formatDecimal(metrics.reviewsPerPlace),
                  detail: 'Moyenne de contributions par lieu',
                ),
                _MetricCard(
                  icon: Icons.speed_outlined,
                  label: 'Performance',
                  value: '${metrics.loadDuration.inMilliseconds} ms',
                  detail: 'Chargement des métriques',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _formatDecimal(double value) {
    return value.toStringAsFixed(1);
  }

  String _formatPercent(double value) {
    return '${(value * 100).round()}%';
  }
}

class _MetricSurface extends StatelessWidget {
  final Widget child;

  const _MetricSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String detail;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return _MetricSurface(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.accent, size: 22),
            const Spacer(),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              detail,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _PropositionCard extends StatelessWidget {
  final PropositionLieu proposition;
  final VoidCallback onValidate;
  final VoidCallback onReject;

  const _PropositionCard({
    required this.proposition,
    required this.onValidate,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: BorderRadius.circular(8),
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
                    proposition.nom,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _CategoryTag(label: proposition.categorie.label),
              ],
            ),
            if (proposition.description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                proposition.description,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Lat ${proposition.latitude}, Lng ${proposition.longitude}'
              '${proposition.heures.isNotEmpty ? ' - ${proposition.heures}' : ''}',
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorText,
                      side: const BorderSide(color: AppColors.errorText),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text('Refuser'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: onValidate,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text('Valider'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  final String label;

  const _CategoryTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
          label,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  final String message;

  const _InlineMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 16,
          height: 1.4,
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final String message;

  const _CenteredMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
