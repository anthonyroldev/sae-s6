import 'package:flutter_test/flutter_test.dart';
import 'package:le_repere/core/utils/email_domain_validator.dart';

void main() {
  group('EmailDomainValidator', () {
    test('allows exact institutional domains', () {
      expect(
        EmailDomainValidator.isAllowedSignupEmail('student@insa-hdf.fr'),
        isTrue,
      );
      expect(
        EmailDomainValidator.isAllowedSignupEmail('student@uphf.fr'),
        isTrue,
      );
      expect(
        EmailDomainValidator.isAllowedSignupEmail('student@univ-lille.fr'),
        isTrue,
      );
    });

    test('allows institutional subdomains', () {
      expect(
        EmailDomainValidator.isAllowedSignupEmail('student@etu.univ-lille.fr'),
        isTrue,
      );
    });

    test('normalizes uppercase addresses', () {
      expect(
        EmailDomainValidator.isAllowedSignupEmail('STUDENT@ETU.UPHF.FR'),
        isTrue,
      );
    });

    test('rejects suffix traps', () {
      expect(
        EmailDomainValidator.isAllowedSignupEmail('student@fakeinsa-hdf.fr'),
        isFalse,
      );
      expect(
        EmailDomainValidator.isAllowedSignupEmail(
          'student@insa-hdf.fr.attacker.com',
        ),
        isFalse,
      );
    });

    test('rejects malformed addresses', () {
      expect(EmailDomainValidator.isValidEmail('student'), isFalse);
      expect(EmailDomainValidator.isAllowedSignupEmail('@uphf.fr'), isFalse);
      expect(
        EmailDomainValidator.isAllowedSignupEmail('student@uphf'),
        isFalse,
      );
    });
  });
}
