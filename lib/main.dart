import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:le_repere/core/constants/app_colors.dart';
import 'package:le_repere/firebase_options.dart';
import 'package:le_repere/pages/splash_page.dart';

/// App entry point.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
