import 'dart:async';

import 'package:le_repere/data/sources/auth_source.dart';

/// In-memory [AuthSource] for widget tests.
class FakeAuthSource implements AuthSource {
  /// Login requests, in order.
  final List<({String email, String password})> signIns = [];

  /// Signup requests, in order.
  final List<({String email, String password, String name})> signUps = [];

  /// Number of times [signOut] was called.
  int signOutCount = 0;

  /// When set, [signIn] throws this instead of succeeding.
  Object? throwOnSignIn;

  /// When set, [signUp] throws this instead of succeeding.
  Object? throwOnSignUp;

  bool _signedIn = false;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  @override
  Future<void> signIn({required String email, required String password}) async {
    final error = throwOnSignIn;
    if (error != null) {
      throw error;
    }
    signIns.add((email: email, password: password));
    _setSignedIn();
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final error = throwOnSignUp;
    if (error != null) {
      throw error;
    }
    signUps.add((email: email, password: password, name: name));
    _setSignedIn();
  }

  void _setSignedIn() {
    _signedIn = true;
    _controller.add(true);
  }

  @override
  Future<void> signOut() async {
    signOutCount++;
    _signedIn = false;
    _controller.add(false);
  }

  @override
  bool get isSignedIn => _signedIn;

  @override
  Stream<bool> get authStateChanges => _controller.stream;

  /// Closes the internal stream controller.
  void dispose() => _controller.close();
}
