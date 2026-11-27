import 'package:flutter_test/flutter_test.dart';
import 'package:aku_motor/features/motors/domain/motor.dart';
import 'package:aku_motor/features/motors/domain/motor_validation.dart';

void main() {
  group('MotorValidation & Motor Domain Unit Tests', () {
    test('valid MotorDraft passes validation with zero errors', () {
      const draft = MotorDraft(
        brand: 'Honda',
        model: 'Vario 160',
        year: 2023,
        currentKilometer: 14500,
      );
      final errors = MotorValidation.validate(draft);
      expect(errors, isEmpty);
      expect(MotorValidation.isValid(draft), isTrue);
    });

    test('empty brand returns validation error', () {
      const draft = MotorDraft(
        brand: '',
        model: 'Vario 160',
        year: 2023,
        currentKilometer: 14500,
      );
      final errors = MotorValidation.validate(draft);
      expect(errors['brand'], contains('Merek motor wajib diisi'));
      expect(MotorValidation.isValid(draft), isFalse);
    });

    test('brand less than 2 characters returns error', () {
      const draft = MotorDraft(
        brand: 'H',
        model: 'Vario',
        year: 2023,
        currentKilometer: 14500,
      );
      final errors = MotorValidation.validate(draft);
      expect(errors['brand'], contains('minimal 2 karakter'));
    });

    test('brand exceeding 50 characters returns error', () {
      final draft = MotorDraft(
        brand: 'A' * 51,
        model: 'Vario',
        year: 2023,
        currentKilometer: 14500,
      );
      final errors = MotorValidation.validate(draft);
      expect(errors['brand'], contains('maksimal 50 karakter'));
    });

    test('empty model returns validation error', () {
      const draft = MotorDraft(
        brand: 'Yamaha',
        model: '',
        year: 2023,
        currentKilometer: 10000,
      );
      final errors = MotorValidation.validate(draft);
      expect(errors['model'], contains('Model motor wajib diisi'));
    });

    test('model less than 2 characters returns error', () {
      const draft = MotorDraft(
        brand: 'Yamaha',
        model: 'N',
        year: 2023,
        currentKilometer: 10000,
      );
      final errors = MotorValidation.validate(draft);
      expect(errors['model'], contains('minimal 2 karakter'));
    });

    test('model exceeding 50 characters returns error', () {
      final draft = MotorDraft(
        brand: 'Yamaha',
        model: 'M' * 55,
        year: 2023,
        currentKilometer: 10000,
      );
      final errors = MotorValidation.validate(draft);
      expect(errors['model'], contains('maksimal 50 karakter'));
    });

    test('year below minYear (1900) returns error', () {
      const draft = MotorDraft(
        brand: 'Honda',
        model: 'Super Cub',
        year: 1899,
        currentKilometer: 50000,
      );
      final errors = MotorValidation.validate(draft);
      expect(errors['year'], contains('harus antara 1900'));
    });

    test('year above maxYear returns error', () {
      final now = DateTime(2026, 1, 1);
      final draft = MotorDraft(
        brand: 'Honda',
        model: 'Super Cub',
        year: 2028, // max is 2026 + 1 = 2027
        currentKilometer: 0,
      );
      final errors = MotorValidation.validate(draft, now: now);
      expect(errors['year'], contains('harus antara 1900'));
    });

    test('boundary year 1900 is valid', () {
      const draft = MotorDraft(
        brand: 'Antique',
        model: 'Motorcycle',
        year: 1900,
        currentKilometer: 1000,
      );
      final errors = MotorValidation.validate(draft);
      expect(errors.containsKey('year'), isFalse);
    });

    test('boundary next year is valid for upcoming model year', () {
      final now = DateTime(2026, 10, 1);
      final draft = MotorDraft(
        brand: 'Honda',
        model: 'PCX 160 2027 Edition',
        year: 2027,
        currentKilometer: 0,
      );
      final errors = MotorValidation.validate(draft, now: now);
      expect(errors.containsKey('year'), isFalse);
    });

    test('negative currentKilometer returns error', () {
      const draft = MotorDraft(
        brand: 'Honda',
        model: 'Beat',
        year: 2022,
        currentKilometer: -10,
      );
      final errors = MotorValidation.validate(draft);
      expect(errors['currentKilometer'], contains('tidak boleh bernilai negatif'));
    });

    test('currentKilometer exceeding 1,000,000 returns error', () {
      const draft = MotorDraft(
        brand: 'Honda',
        model: 'Beat',
        year: 2022,
        currentKilometer: 1000001,
      );
      final errors = MotorValidation.validate(draft);
      expect(errors['currentKilometer'], contains('melebihi batas wajar'));
    });

    test('0 kilometer is valid for brand new motorcycle', () {
      const draft = MotorDraft(
        brand: 'Honda',
        model: 'Beat Street',
        year: 2026,
        currentKilometer: 0,
      );
      final errors = MotorValidation.validate(draft);
      expect(errors, isEmpty);
    });

    test('Motor copyWith updates currentKilometer correctly', () {
      final motor = Motor(
        id: 'm-1',
        brand: 'Yamaha',
        model: 'Aerox 155',
        year: 2022,
        currentKilometer: 20000,
        createdAt: DateTime(2022, 1, 1),
      );
      final updated = motor.copyWith(currentKilometer: 25000);
      expect(updated.currentKilometer, 25000);
      expect(updated.id, 'm-1');
      expect(updated.brand, 'Yamaha');
    });

    test('Motor toJson produces PascalCase keys for backend compatibility', () {
      final date = DateTime(2026, 1, 1);
      final motor = Motor(
        id: 'm-10',
        brand: 'Vespa',
        model: 'Sprint S',
        year: 2024,
        currentKilometer: 5000,
        createdAt: date,
      );
      final json = motor.toJson();
      expect(json['Id'], 'm-10');
      expect(json['Brand'], 'Vespa');
      expect(json['Model'], 'Sprint S');
      expect(json['Year'], 2024);
      expect(json['CurrentKilometer'], 5000);
      expect(json['CreatedAt'], date.toIso8601String());
    });
  });
}
