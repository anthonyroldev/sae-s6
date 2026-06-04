/// Validates email addresses and the institutional domains allowed at signup.
abstract final class EmailDomainValidator {
  /// Institutional domains allowed to create an account.
  static const allowedSignupDomains = {
    'insa-hdf.fr',
    'uphf.fr',
    'univ-lille.fr',
  };

  static final _emailPattern = RegExp(
    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    caseSensitive: false,
  );

  /// Returns whether [email] has a valid basic email structure.
  static bool isValidEmail(String email) {
    return _emailPattern.hasMatch(email.trim());
  }

  /// Returns whether [email] belongs to an allowed institutional domain.
  static bool isAllowedSignupEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    if (!isValidEmail(normalizedEmail)) {
      return false;
    }

    final domain = normalizedEmail.split('@').last;
    return allowedSignupDomains.any(
      (allowedDomain) =>
          domain == allowedDomain || domain.endsWith('.$allowedDomain'),
    );
  }
}
