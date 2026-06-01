import 'dart:async';

import 'package:le_repere/data/sources/auth_source.dart';

/// In-memory [AuthSource] for widget tests.
class FakeAuthSource implements AuthSource {
  /// Emails passed to [sendCode], in order.
  final List<String> sentCodes = [];

  /// (email, code) pairs passed to [verifyCode], in order.
  final List<({String email, String code})> verifiedCodes = [];

  /// Number of times [signOut] was called.
  int signOutCount = 0;

  /// When set, [verifyCode] throws this instead of succeeding.
  Object? throwOnVerify;

  bool _signedIn = false;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  @override
  Future<void> sendCode(String email) async => sentCodes.add(email);

  @override
  Future<void> verifyCode({required String email, required String code}) async {
    final error = throwOnVerify;
    if (error != null) {
      throw error;
    }
    verifiedCodes.add((email: email, code: code));
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
