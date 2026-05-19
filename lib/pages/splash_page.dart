import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'home_page.dart';

/// Splash page shown at app startup.
class SplashPage extends StatefulWidget {
  /// Creates the splash page.
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const Duration _displayDuration = Duration(milliseconds: 2500);
  static const Duration _fadeDuration = Duration(milliseconds: 900);
  static const String _logoPath = 'assets/repere_wordmark.svg';
  static const double _logoWidthFactor = 0.85;
  static const double _logoMinWidth = 250;
  static const double _logoMaxWidth = 350;
  static const double _logoSpacing = 10;
  static const double _textHorizontalPadding = 24;

  bool _isVisible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
    _timer = Timer(_displayDuration, _openHomePage);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _openHomePage() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: AnimatedOpacity(
            opacity: _isVisible ? 1 : 0,
            duration: _fadeDuration,
            curve: Curves.easeOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final rawLogoWidth =
                        constraints.maxWidth * _logoWidthFactor;
                    final logoWidth = rawLogoWidth.clamp(
                      _logoMinWidth,
                      _logoMaxWidth,
                    );
                    return SvgPicture.asset(
                      _logoPath,
                      width: logoWidth,
                      semanticsLabel: 'Le Repère',
                    );
                  },
                ),
                const SizedBox(height: _logoSpacing),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _textHorizontalPadding,
                  ),
                  child: Text(
                    'Le repère pour les étudiants, par les étudiants',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
