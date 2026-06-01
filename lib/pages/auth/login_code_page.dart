import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/sources/auth_source.dart';
import '../../data/sources/auth_supabase_source.dart';

/// Second login step: the user enters the 6-digit code received by email.
class LoginCodePage extends StatefulWidget {
  /// Email the code was sent to.
  final String email;

  /// Auth backend (injected for testing).
  final AuthSource authSource;

  /// Creates the code-entry page.
  LoginCodePage({super.key, required this.email, AuthSource? authSource})
    : authSource = authSource ?? AuthSupabaseSource();

  @override
  State<LoginCodePage> createState() => _LoginCodePageState();
}

class _LoginCodePageState extends State<LoginCodePage> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.length < 6) {
      setState(() => _error = 'Code invalide');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await widget.authSource.verifyCode(email: widget.email, code: code);
      if (!mounted) {
        return;
      }
      // The AuthGate stream now renders HomePage at the root route; drop the
      // pushed login routes so the user lands on it instead of this page.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'Code incorrect ou expiré');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resend() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await widget.authSource.sendCode(widget.email);
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() => _error = "Échec de l'envoi du code");
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
      appBar: AppBar(backgroundColor: AppColors.background),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Entre le code reçu à ${widget.email}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                key: const Key('code-field'),
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Code à 6 chiffres',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(_error!, style: const TextStyle(color: AppColors.errorText)),
              ],
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                key: const Key('verify-code-button'),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Se connecter'),
              ),
              TextButton(
                key: const Key('resend-code-button'),
                onPressed: _isLoading ? null : _resend,
                child: const Text('Renvoyer le code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
