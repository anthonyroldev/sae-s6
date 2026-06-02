import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/models/proposition_lieu.dart';
import '../../data/sources/proposition_source.dart';
import '../../data/sources/proposition_supabase_source.dart';
import '../../data/sources/role_source.dart';
import '../../data/sources/role_supabase_source.dart';

/// Moderation screen listing pending place proposals.
///
/// Reachable only by moderators and administrators. Each proposal can be
/// validated (publishes the place) or rejected.
class ModerationPropositionsPage extends StatefulWidget {
  /// Proposal backend (injected for testing).
  final PropositionSource propositionSource;

  /// Role backend, used to guard access (injected for testing).
  final RoleSource roleSource;

  /// Creates the moderation page.
  ModerationPropositionsPage({
    super.key,
    PropositionSource? propositionSource,
    RoleSource? roleSource,
  }) : propositionSource = propositionSource ?? PropositionSupabaseSource(),
       roleSource = roleSource ?? RoleSupabaseSource();

  @override
  State<ModerationPropositionsPage> createState() =>
      _ModerationPropositionsPageState();
}

class _ModerationPropositionsPageState
    extends State<ModerationPropositionsPage> {
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
      ),
      body: widget.roleSource.currentRole.canModerate
          ? _buildQueue()
          : const _CenteredMessage('Accès réservé aux modérateurs.'),
    );
  }

  Widget _buildQueue() {
    return StreamBuilder<List<PropositionLieu>>(
      stream: widget.propositionSource.watchEnAttente(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _CenteredMessage('Erreur de chargement\n${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final propositions = snapshot.data ?? const <PropositionLieu>[];
        if (propositions.isEmpty) {
          return const _CenteredMessage('Aucune proposition en attente.');
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
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
        SnackBar(content: Text('« ${proposition.nom} » publié.')),
      );
    } on Object catch (error) {
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
        SnackBar(content: Text('« ${proposition.nom} » refusé.')),
      );
    } on Object catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Échec du refus : $error')),
      );
    }
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
        borderRadius: BorderRadius.circular(12),
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
              '${proposition.heures.isNotEmpty ? ' · ${proposition.heures}' : ''}',
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
        borderRadius: BorderRadius.circular(999),
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
