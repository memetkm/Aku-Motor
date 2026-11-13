import 'package:aku_motor/features/auth/domain/validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ValidationRules', () {
    test('validateName validasi string kosong atau null', () {
      expect(ValidationRules.validateName(null), 'Nama wajib diisi');
      expect(ValidationRules.validateName('   '), 'Nama wajib diisi');
      expect(
        ValidationRules.validateName('', emptyMessage: 'Nama lengkap wajib diisi'),
        'Nama lengkap wajib diisi',
      );
      expect(ValidationRules.validateName('Budi Santoso'), isNull);
    });

    test('validateEmail memvalidasi format email', () {
      expect(ValidationRules.validateEmail(null), 'Email wajib diisi');
      expect(ValidationRules.validateEmail(''), 'Email wajib diisi');
      expect(ValidationRules.validateEmail('invalid-email'), 'Format email tidak valid');
      expect(ValidationRules.validateEmail('user@test'), 'Format email tidak valid');
      expect(ValidationRules.validateEmail('budi@akumotor.id'), isNull);
    });

    test('validatePhone memvalidasi nomor telepon dan batas panjang', () {
      expect(ValidationRules.validatePhone(null), 'Nomor HP wajib diisi');
      expect(ValidationRules.validatePhone(''), 'Nomor HP wajib diisi');
      expect(
        ValidationRules.validatePhone('12345', minLength: 8),
        'Nomor HP terlalu pendek',
      );
      expect(ValidationRules.validatePhone('081234567890', minLength: 8), isNull);
    });

    test('validatePassword memvalidasi batas minimal karakter', () {
      expect(ValidationRules.validatePassword(null), 'Kata sandi wajib diisi');
      expect(ValidationRules.validatePassword('12345'), 'Kata sandi minimal 6 karakter');
      expect(ValidationRules.validatePassword('password123'), isNull);
    });

    test('validateConfirmPassword memvalidasi kecocokan kata sandi', () {
      expect(
        ValidationRules.validateConfirmPassword('password123', 'different'),
        'Konfirmasi kata sandi tidak cocok',
      );
      expect(
        ValidationRules.validateConfirmPassword('password123', 'password123'),
        isNull,
      );
    });

    test('validateRequired memvalidasi field wajib diisi', () {
      expect(ValidationRules.validateRequired(null), 'Wajib diisi');
      expect(ValidationRules.validateRequired('   '), 'Wajib diisi');
      expect(ValidationRules.validateRequired('Ada isi'), isNull);
    });
  });
}
