import 'package:flutter/material.dart';
import 'package:le_repere/core/constants/app_colors.dart';
import 'package:le_repere/pages/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase project URL, injected at build time via
/// `--dart-define=SUPABASE_URL=...`.
const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');

/// Supabase anonymous (public) key, injected at build time via
/// `--dart-define=SUPABASE_ANON_KEY=...`.
const String _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

/// App entry point. The app uses Supabase for both auth and data.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  assert(
    _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty,
    'Missing Supabase config. Run with '
    '--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
  );

  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);

  runApp(const MainApp());
}

/// Root application widget.
class MainApp extends StatelessWidget {
  /// Creates the root application widget.
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Le Repère',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
