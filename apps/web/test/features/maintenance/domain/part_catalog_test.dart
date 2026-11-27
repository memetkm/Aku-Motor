import 'package:flutter_test/flutter_test.dart';
import 'package:aku_motor/features/maintenance/domain/part_catalog.dart';

void main() {
  group('PartCatalog Domain Tests', () {
    test('PartCatalog contains Oli Mesin with expected intervals', () {
      final info = PartCatalog.getInfo('Oli Mesin');
      expect(info.name, 'Oli Mesin');
      expect(info.intervalKilometer, 3000);
      expect(info.intervalMonth, 2);
    });

    test('PartCatalog contains V-Belt with expected intervals', () {
      final info = PartCatalog.getInfo('V-Belt');
      expect(info.name, 'V-Belt');
      expect(info.intervalKilometer, 24000);
      expect(info.intervalMonth, 24);
    });

    test('PartCatalog contains Kampas Rem with expected intervals', () {
      final info = PartCatalog.getInfo('Kampas Rem');
      expect(info.name, 'Kampas Rem');
      expect(info.intervalKilometer, 10000);
      expect(info.intervalMonth, 12);
    });

    test('PartCatalog contains Ban with expected intervals', () {
      final info = PartCatalog.getInfo('Ban');
      expect(info.name, 'Ban');
      expect(info.intervalKilometer, 12000);
      expect(info.intervalMonth, 18);
    });

    test('PartCatalog contains Roller CVT with expected intervals', () {
      final info = PartCatalog.getInfo('Roller CVT');
      expect(info.name, 'Roller CVT');
      expect(info.intervalKilometer, 20000);
      expect(info.intervalMonth, 20);
    });

    test('PartCatalog contains Oli Gardan with expected intervals', () {
      final info = PartCatalog.getInfo('Oli Gardan');
      expect(info.name, 'Oli Gardan');
      expect(info.intervalKilometer, 8000);
      expect(info.intervalMonth, 6);
    });

    test('PartCatalog contains Aki with expected intervals', () {
      final info = PartCatalog.getInfo('Aki');
      expect(info.name, 'Aki');
      expect(info.intervalKilometer, 20000);
      expect(info.intervalMonth, 24);
    });

    test('PartCatalog contains Filter Udara with expected intervals', () {
      final info = PartCatalog.getInfo('Filter Udara');
      expect(info.name, 'Filter Udara');
      expect(info.intervalKilometer, 10000);
      expect(info.intervalMonth, 10);
    });

    test('All catalog items have positive intervalKilometer', () {
      for (final entry in PartCatalog.items.entries) {
        expect(
          entry.value.intervalKilometer,
          greaterThan(0),
          reason: '${entry.key} must have positive intervalKilometer',
        );
      }
    });

    test('All catalog items have positive intervalMonth', () {
      for (final entry in PartCatalog.items.entries) {
        expect(
          entry.value.intervalMonth,
          greaterThan(0),
          reason: '${entry.key} must have positive intervalMonth',
        );
      }
    });

    test('All catalog items have estimatedCostNow significantly lower than estimatedCostLater', () {
      for (final entry in PartCatalog.items.entries) {
        expect(
          entry.value.estimatedCostNow,
          lessThan(entry.value.estimatedCostLater),
          reason: '${entry.key} costNow must be cheaper than costLater to incentivize preventive maintenance',
        );
      }
    });

    test('All catalog items have informative vulnerability reasons', () {
      for (final entry in PartCatalog.items.entries) {
        expect(entry.value.vulnerabilityReason, isNotEmpty);
        expect(entry.value.vulnerabilityReason.length, greaterThan(20));
      }
    });

    test('All catalog items define light, medium, and fatal consequences', () {
      for (final entry in PartCatalog.items.entries) {
        expect(entry.value.consequenceLight, isNotEmpty);
        expect(entry.value.consequenceMedium, isNotEmpty);
        expect(entry.value.consequenceFatal, isNotEmpty);
      }
    });

    test('getInfo returns default fallback info for unrecognized part name', () {
      final fallback = PartCatalog.getInfo('Komponen Misterius');
      expect(fallback.name, 'Komponen Motor');
      expect(fallback.intervalKilometer, greaterThan(0));
      expect(fallback.intervalMonth, greaterThan(0));
      expect(fallback.consequenceFatal, isNotEmpty);
    });

    test('getInfo is case sensitive with catalog keys', () {
      final info = PartCatalog.getInfo('Ban');
      expect(info.name, 'Ban');
    });

    test('PartCategory enum values contain core motorcycle maintenance areas', () {
      expect(PartCategory.values, contains(PartCategory.oliMesin));
      expect(PartCategory.values, contains(PartCategory.vbelt));
      expect(PartCategory.values, contains(PartCategory.kampasRem));
      expect(PartCategory.values, contains(PartCategory.ban));
      expect(PartCategory.values, contains(PartCategory.aki));
    });
  });
}
