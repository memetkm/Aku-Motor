import 'package:flutter_test/flutter_test.dart';
import 'package:aku_motor/features/maintenance/domain/maintenance_record.dart';

void main() {
  group('MaintenanceRecord Domain & Calculation Tests', () {
    test('calculateDueDate regular month addition', () {
      final base = DateTime(2026, 3, 15);
      final due = MaintenanceRecord.calculateDueDate(base, 2);
      expect(due.year, 2026);
      expect(due.month, 5);
      expect(due.day, 15);
    });

    test('calculateDueDate handles year rollover', () {
      final base = DateTime(2026, 11, 10);
      final due = MaintenanceRecord.calculateDueDate(base, 3);
      expect(due.year, 2027);
      expect(due.month, 2);
      expect(due.day, 10);
    });

    test('calculateDueDate clamps day on month with fewer days (Jan 31 + 1 month -> Feb 28)', () {
      final base = DateTime(2026, 1, 31);
      final due = MaintenanceRecord.calculateDueDate(base, 1);
      expect(due.year, 2026);
      expect(due.month, 2);
      expect(due.day, 28);
    });

    test('calculateDueDate clamps day on leap year (Jan 31 + 1 month in 2024 -> Feb 29)', () {
      final base = DateTime(2024, 1, 31);
      final due = MaintenanceRecord.calculateDueDate(base, 1);
      expect(due.year, 2024);
      expect(due.month, 2);
      expect(due.day, 29);
    });

    test('calculateDueDate clamps day on 30-day month (Mar 31 + 1 month -> Apr 30)', () {
      final base = DateTime(2026, 3, 31);
      final due = MaintenanceRecord.calculateDueDate(base, 1);
      expect(due.year, 2026);
      expect(due.month, 4);
      expect(due.day, 30);
    });

    test('calculateRemainingKm calculates positive remaining km correctly', () {
      // Oli Mesin interval = 3000 km
      final record = MaintenanceRecord(
        id: 'rec-1',
        motorId: 'm-1',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Ganti oli',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(record.calculateRemainingKm(11000), 2000);
    });

    test('calculateRemainingKm calculates zero remaining km at limit', () {
      final record = MaintenanceRecord(
        id: 'rec-2',
        motorId: 'm-1',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Ganti oli',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(record.calculateRemainingKm(13000), 0);
    });

    test('calculateRemainingKm calculates negative remaining km when overdue', () {
      final record = MaintenanceRecord(
        id: 'rec-3',
        motorId: 'm-1',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Ganti oli',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(record.calculateRemainingKm(13500), -500);
    });

    test('calculateRemainingDays calculates days remaining to due date', () {
      // Oli Mesin interval = 2 months
      final record = MaintenanceRecord(
        id: 'rec-4',
        motorId: 'm-1',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Ganti oli',
        createdAt: DateTime(2026, 1, 1),
      );
      // Due date is 2026-03-01
      final now = DateTime(2026, 2, 1);
      expect(record.calculateRemainingDays(now: now), 28);
    });

    test('calculateRemainingDays returns negative when past due date', () {
      final record = MaintenanceRecord(
        id: 'rec-5',
        motorId: 'm-1',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Ganti oli',
        createdAt: DateTime(2026, 1, 1),
      );
      final now = DateTime(2026, 3, 5);
      expect(record.calculateRemainingDays(now: now), -4);
    });

    test('calculateRemainingDays returns zero on exact due date', () {
      final record = MaintenanceRecord(
        id: 'rec-6',
        motorId: 'm-1',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Ganti oli',
        createdAt: DateTime(2026, 1, 1),
      );
      final now = DateTime(2026, 3, 1);
      expect(record.calculateRemainingDays(now: now), 0);
    });

    test('calculateStatus returns safe when condition is normal', () {
      final record = MaintenanceRecord(
        id: 'rec-7',
        motorId: 'm-1',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Aman',
        createdAt: DateTime(2026, 1, 1),
      );
      // 10500 km -> 2500 km remaining (interval 3000, 20% is 600)
      // now 2026-01-15 -> due 2026-03-01, ~45 days remaining (>14)
      final status = record.calculateStatus(10500, now: DateTime(2026, 1, 15));
      expect(status, MaintenanceStatus.safe);
    });

    test('calculateStatus returns warning when remaining km <= 20% of interval', () {
      final record = MaintenanceRecord(
        id: 'rec-8',
        motorId: 'm-1',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Perhatian',
        createdAt: DateTime(2026, 1, 1),
      );
      // Interval = 3000, 20% = 600 km threshold. At 12500, remaining = 500 km.
      final status = record.calculateStatus(12500, now: DateTime(2026, 1, 15));
      expect(status, MaintenanceStatus.warning);
    });

    test('calculateStatus returns warning when remaining days <= 14', () {
      final record = MaintenanceRecord(
        id: 'rec-9',
        motorId: 'm-1',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Mendekati hari',
        createdAt: DateTime(2026, 1, 1),
      );
      // Km is fine (10500, 2500 remaining), but date is 10 days before due 2026-03-01
      final status = record.calculateStatus(10500, now: DateTime(2026, 2, 19));
      expect(status, MaintenanceStatus.warning);
    });

    test('calculateStatus returns urgent when remaining km <= 0', () {
      final record = MaintenanceRecord(
        id: 'rec-10',
        motorId: 'm-1',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Urgent km',
        createdAt: DateTime(2026, 1, 1),
      );
      final status = record.calculateStatus(13000, now: DateTime(2026, 1, 15));
      expect(status, MaintenanceStatus.urgent);
    });

    test('calculateStatus returns urgent when remaining days <= 0', () {
      final record = MaintenanceRecord(
        id: 'rec-11',
        motorId: 'm-1',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Urgent days',
        createdAt: DateTime(2026, 1, 1),
      );
      final status = record.calculateStatus(10500, now: DateTime(2026, 3, 2));
      expect(status, MaintenanceStatus.urgent);
    });

    test('calculateStatus urgent takes precedence over warning', () {
      final record = MaintenanceRecord(
        id: 'rec-12',
        motorId: 'm-1',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Urgent precedence',
        createdAt: DateTime(2026, 1, 1),
      );
      // Both km is negative and days are past
      final status = record.calculateStatus(14000, now: DateTime(2026, 3, 10));
      expect(status, MaintenanceStatus.urgent);
    });

    test('copyWith updates id correctly', () {
      final original = MaintenanceRecord(
        id: 'rec-orig',
        motorId: 'm-1',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Notes',
        createdAt: DateTime(2026, 1, 1),
      );
      final updated = original.copyWith(id: 'rec-new');
      expect(updated.id, 'rec-new');
      expect(updated.motorId, original.motorId);
    });

    test('copyWith updates lastReplacedKilometer and notes', () {
      final original = MaintenanceRecord(
        id: 'rec-orig',
        motorId: 'm-1',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Old notes',
        createdAt: DateTime(2026, 1, 1),
      );
      final updated = original.copyWith(
        lastReplacedKilometer: 12000,
        notes: 'Updated notes',
      );
      expect(updated.lastReplacedKilometer, 12000);
      expect(updated.notes, 'Updated notes');
      expect(updated.partType, 'Oli Mesin');
    });

    test('copyWith preserves all fields when arguments are null', () {
      final original = MaintenanceRecord(
        id: 'rec-orig',
        motorId: 'm-1',
        partType: 'Ban',
        lastReplacedAt: DateTime(2026, 2, 1),
        lastReplacedKilometer: 20000,
        notes: 'Original',
        createdAt: DateTime(2026, 2, 1),
        photoUrl: 'http://img.test',
      );
      final clone = original.copyWith();
      expect(clone.id, original.id);
      expect(clone.partType, original.partType);
      expect(clone.photoUrl, original.photoUrl);
    });

    test('toJson produces valid map representation', () {
      final date = DateTime(2026, 1, 1, 10, 0);
      final record = MaintenanceRecord(
        id: 'rec-json',
        motorId: 'm-2',
        partType: 'Kampas Rem',
        lastReplacedAt: date,
        lastReplacedKilometer: 15000,
        notes: 'Ganti kampas depan',
        createdAt: date,
        photoUrl: 'https://example.com/photo.jpg',
      );
      final json = record.toJson();
      expect(json['id'], 'rec-json');
      expect(json['motorId'], 'm-2');
      expect(json['partType'], 'Kampas Rem');
      expect(json['lastReplacedKilometer'], 15000);
      expect(json['notes'], 'Ganti kampas depan');
      expect(json['photoUrl'], 'https://example.com/photo.jpg');
    });

    test('fromJson deserializes valid JSON into MaintenanceRecord', () {
      final json = {
        'id': 'rec-from-json',
        'motorId': 'm-9',
        'partType': 'V-Belt',
        'lastReplacedAt': '2026-04-10T08:30:00.000',
        'lastReplacedKilometer': 24000,
        'notes': 'Paket CVT',
        'createdAt': '2026-04-10T08:30:00.000',
        'photoUrl': 'photo.png',
      };
      final record = MaintenanceRecord.fromJson(json);
      expect(record.id, 'rec-from-json');
      expect(record.partType, 'V-Belt');
      expect(record.lastReplacedKilometer, 24000);
      expect(record.photoUrl, 'photo.png');
    });

    test('fromJson defaults photoUrl to empty string when null', () {
      final json = {
        'id': 'rec-no-photo',
        'motorId': 'm-9',
        'partType': 'Ban',
        'lastReplacedAt': '2026-04-10T08:30:00.000',
        'lastReplacedKilometer': 5000,
        'notes': 'Tanpa foto',
        'createdAt': '2026-04-10T08:30:00.000',
      };
      final record = MaintenanceRecord.fromJson(json);
      expect(record.photoUrl, '');
    });

    test('MaintenanceStatus labels and descriptions are descriptive', () {
      expect(MaintenanceStatus.safe.label, 'Aman');
      expect(MaintenanceStatus.warning.label, 'Perhatian');
      expect(MaintenanceStatus.urgent.label, 'Ganti Segera');
      expect(MaintenanceStatus.safe.description, isNotEmpty);
      expect(MaintenanceStatus.warning.description, isNotEmpty);
      expect(MaintenanceStatus.urgent.description, isNotEmpty);
    });
  });
}
