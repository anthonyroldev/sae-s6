import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../data/models/avis_with_auteur.dart';
import '../data/models/lieu.dart';
import '../data/sources/avis_supabase_source.dart';
import 'lieu/avis_card.dart';

/// Full list of reviews for a place.
class AvisListPage extends StatefulWidget {
  final Lieu lieu;

  const AvisListPage({super.key, required this.lieu});

  @override
  State<AvisListPage> createState() => _AvisListPageState();
}

class _AvisListPageState extends State<AvisListPage> {
  final _avisSource = AvisSupabaseSource();
  late Future<List<AvisWithAuteur>> _avisFuture;

  @override
  void initState() {
    super.initState();
    _avisFuture = _avisSource.fetchForLieu(widget.lieu.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Avis — ${widget.lieu.nom}',
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
      body: FutureBuilder<List<AvisWithAuteur>>(
        future: _avisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Erreur de chargement des avis',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 16,
                ),
              ),
            );
          }
          final avisList = snapshot.data ?? const <AvisWithAuteur>[];
          if (avisList.isEmpty) {
            return const Center(
              child: Text(
                'Aucun avis pour le moment.',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: avisList.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, index) => AvisCard(item: avisList[index]),
          );
        },
      ),
    );
  }
}
