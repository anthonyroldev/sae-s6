import 'package:flutter/material.dart';

/// App entry point.
void main() {
  runApp(const MainApp());
}

/// Root application widget.
class MainApp extends StatelessWidget {
  /// Creates the root application widget.
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Le Repere',
      home: Scaffold(body: SizedBox.shrink()),
    );
  }
}
