import 'package:aku_motor/features/motors/domain/motor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Unit Test 1 (model valid): parsing JSON valid menghasilkan entitas Motor yang benar', () {
    final validJson = {
      'Id': 101,
      'Brand': 'Honda',
      'Model': 'Vario 160',
      'Year': 2024,
      'CurrentKilometer': 8500,
      'CreatedAt': '2026-10-01T10:00:00.000Z',
    };

    final motor = Motor.fromJson(validJson);

    expect(motor.id, '101');
    expect(motor.brand, 'Honda');
    expect(motor.model, 'Vario 160');
    expect(motor.year, 2024);
    expect(motor.currentKilometer, 8500);
    expect(motor.createdAt, DateTime.parse('2026-10-01T10:00:00.000Z'));
  });

  test('Unit Test 2 (model invalid): parsing JSON tanpa atribut wajib melempar FormatException', () {
    final missingBrandJson = {
      'Id': 102,
      // 'Brand' tidak disertakan
      'Model': 'NMAX 155',
      'Year': 2023,
      'CurrentKilometer': 12000,
    };

    expect(
      () => Motor.fromJson(missingBrandJson),
      throwsA(isA<FormatException>()),
    );

    final invalidYearJson = {
      'Id': 103,
      'Brand': 'Yamaha',
      'Model': 'Aerox',
      'Year': 'bukan_angka_tahun',
      'CurrentKilometer': 5000,
    };

    expect(
      () => Motor.fromJson(invalidYearJson),
      throwsA(isA<FormatException>()),
    );
  });

  test('Unit Test Model: serialisasi toJson menghasilkan Map yang sesuai skema API backend', () {
    final motor = Motor(
      id: '201',
      brand: 'Kawasaki',
      model: 'Ninja 250',
      year: 2023,
      currentKilometer: 4500,
      createdAt: DateTime.parse('2026-10-15T08:00:00.000Z'),
    );

    final json = motor.toJson();

    expect(json['Id'], '201');
    expect(json['Brand'], 'Kawasaki');
    expect(json['Model'], 'Ninja 250');
    expect(json['Year'], 2023);
    expect(json['CurrentKilometer'], 4500);
    expect(json['CreatedAt'], '2026-10-15T08:00:00.000Z');
  });

  test('Unit Test Model: copyWith memperbarui properti tanpa mutasi objek asli', () {
    final original = Motor(
      id: '202',
      brand: 'Yamaha',
      model: 'Mio M3',
      year: 2021,
      currentKilometer: 25000,
      createdAt: DateTime(2026),
    );

    final updated = original.copyWith(
      model: 'Mio S',
      currentKilometer: 26000,
    );

    expect(updated.id, '202');
    expect(updated.brand, 'Yamaha');
    expect(updated.model, 'Mio S');
    expect(updated.currentKilometer, 26000);
    expect(original.model, 'Mio M3'); // objek asli tidak berubah
  });

  test('Unit Test MotorDraft: serialisasi toJson menghasilkan payload POST/PUT yang tepat', () {
    const draft = MotorDraft(
      brand: 'Honda',
      model: 'PCX 160',
      year: 2024,
      currentKilometer: 3200,
    );

    final json = draft.toJson();

    expect(json['Brand'], 'Honda');
    expect(json['Model'], 'PCX 160');
    expect(json['Year'], 2024);
    expect(json['CurrentKilometer'], 3200);
  });
}

