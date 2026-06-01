import 'package:flutter/material.dart';

import '../../data/sources/auth_source.dart';
import '../../data/sources/auth_supabase_source.dart';
import '../home_page.dart';
import 'login_email_page.dart';

/// Routes to [HomePage] when signed in, otherwise to the login flow.
class AuthGate extends StatelessWidget {
  /// Auth backend (injected for testing).
  final AuthSource authSource;

  /// Creates the auth gate.
  AuthGate({super.key, AuthSource? authSource})
    : authSource = authSource ?? AuthSupabaseSource();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      initialData: authSource.isSignedIn,
      stream: authSource.authStateChanges,
      builder: (context, snapshot) {
        final signedIn = snapshot.data ?? false;
        if (signedIn) {
          return const HomePage();
        }
        return LoginEmailPage(authSource: authSource);
      },
    );
  }
}
