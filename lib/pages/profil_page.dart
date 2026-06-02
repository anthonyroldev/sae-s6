import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../data/models/utilisateur.dart';
import '../data/sources/auth_source.dart';
import '../data/sources/auth_supabase_source.dart';
import '../data/sources/utilisateur_source.dart';
import '../data/sources/utilisateur_supabase_source.dart';
import 'profil/profile_header.dart';

/// Profile screen backed by the authenticated Supabase user.
class ProfilPage extends StatelessWidget {
  /// Auth backend injected for testing.
  final AuthSource authSource;

  /// User profile backend injected for testing.
  final UtilisateurSource utilisateurSource;

  /// Creates the profile page.
  ProfilPage({
    super.key,
    AuthSource? authSource,
    UtilisateurSource? utilisateurSource,
  }) : authSource = authSource ?? AuthSupabaseSource(),
       utilisateurSource = utilisateurSource ?? UtilisateurSupabaseSource();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<Utilisateur?>(
          stream: utilisateurSource.watchCurrent(),
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildContent(snapshot)),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: authSource.signOut,
                      child: const Text('Déconnexion'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(AsyncSnapshot<Utilisateur?> snapshot) {
    if (snapshot.hasError) {
      return const Center(child: Text('Erreur de chargement du profil'));
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    final utilisateur = snapshot.data;
    if (utilisateur == null) {
      return const Center(child: Text('Profil introuvable'));
    }
    return ProfileHeader(
      name: utilisateur.nom,
      email: utilisateur.email,
      positionGps: utilisateur.positionGps,
    );
  }
}
