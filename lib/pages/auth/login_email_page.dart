import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/email_domain_validator.dart';
import '../../data/sources/auth_source.dart';
import '../../data/sources/auth_supabase_source.dart';
import 'login_code_page.dart';

/// First authentication step: login or institutional account creation.
class LoginEmailPage extends StatefulWidget {
  /// Auth backend injected for testing.
  final AuthSource authSource;

  /// Creates the email-entry page.
  LoginEmailPage({super.key, AuthSource? authSource})
    : authSource = authSource ?? AuthSupabaseSource();

  @override
  State<LoginEmailPage> createState() => _LoginEmailPageState();
}

class _LoginEmailPageState extends State<LoginEmailPage> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSignup = false;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _setSignupMode(bool isSignup) {
    setState(() {
      _isSignup = isSignup;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim().toLowerCase();
    final name = _nameController.text.trim();
    if (!EmailDomainValidator.isValidEmail(email)) {
      setState(() => _error = 'Adresse email invalide');
      return;
    }
    if (_isSignup && name.isEmpty) {
      setState(() => _error = 'Nom requis');
      return;
    }
    if (_isSignup && !EmailDomainValidator.isAllowedSignupEmail(email)) {
      setState(() => _error = 'Utilisez une adresse email universitaire');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await widget.authSource.sendCode(
        email: email,
        shouldCreateUser: _isSignup,
      );
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => LoginCodePage(
            email: email,
            name: _isSignup ? name : null,
            shouldCreateUser: _isSignup,
            authSource: widget.authSource,
          ),
        ),
      );
    } on Object {
      if (!mounted) {
        return;
      }
      setState(
        () => _error = _isSignup
            ? "Échec de la création du compte"
            : "Échec de l'envoi du code",
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.sizeOf(context).height -
                  MediaQuery.paddingOf(context).vertical -
                  AppSpacing.lg * 2,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SvgPicture.asset(
                      'assets/repere_wordmark.svg',
                      height: 82,
                      semanticsLabel: 'Le Repère',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      _isSignup ? 'Créer un compte' : 'Ravi de vous revoir',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _isSignup
                          ? 'Inscrivez-vous avec votre adresse universitaire.'
                          : 'Connectez-vous avec votre adresse email.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _AuthModeSwitch(
                      isSignup: _isSignup,
                      onChanged: _setSignupMode,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_isSignup) ...[
                      TextField(
                        key: const Key('name-field'),
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          label: 'Nom',
                          icon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    TextField(
                      key: const Key('email-field'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _isLoading ? null : _submit(),
                      decoration: _inputDecoration(
                        label: 'Adresse email',
                        icon: Icons.mail_outline,
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _error!,
                        key: const Key('auth-error'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.errorText,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      key: const Key('send-code-button'),
                      onPressed: _isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.surface,
                        minimumSize: const Size.fromHeight(54),
                        shape: const StadiumBorder(),
                      ),
                      child: _isLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.surface,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isSignup
                                  ? 'Créer mon compte'
                                  : 'Recevoir le code',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'En continuant, vous acceptez nos Conditions Générales '
                      "d'Utilisation et notre Politique de Confidentialité.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.secondaryText),
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
    );
  }
}

class _AuthModeSwitch extends StatelessWidget {
  final bool isSignup;
  final ValueChanged<bool> onChanged;

  const _AuthModeSwitch({required this.isSignup, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Row(
          children: [
            _ModeButton(
              key: const Key('login-mode-button'),
              label: 'Connexion',
              selected: !isSignup,
              onTap: () => onChanged(false),
            ),
            _ModeButton(
              key: const Key('signup-mode-button'),
              label: 'Inscription',
              selected: isSignup,
              onTap: () => onChanged(true),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.secondaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
