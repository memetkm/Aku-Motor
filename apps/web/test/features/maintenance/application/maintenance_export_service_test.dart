import 'package:flutter_test/flutter_test.dart';
import 'package:aku_motor/features/maintenance/application/maintenance_export_service.dart';
import 'package:aku_motor/features/maintenance/domain/maintenance_record.dart';

void main() {
  group('MaintenanceExportService Unit Tests', () {
    test('exportToCsv returns valid header on empty records list', () {
      final csv = MaintenanceExportService.exportToCsv([]);
      expect(csv.trim(), startsWith('ID,MotorID,PartType,LastReplacedDate,LastReplacedKm'));
      expect(csv.trim().split('\n').length, 1);
    });

    test('exportToCsv produces correct CSV line for single record', () {
      final record = MaintenanceRecord(
        id: 'rec-001',
        motorId: 'm-100',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 1, 10),
        lastReplacedKilometer: 5000,
        notes: 'Rutin service',
        createdAt: DateTime(2026, 1, 10),
      );

      final csv = MaintenanceExportService.exportToCsv(
        [record],
        motorKilometers: {'m-100': 6000},
        now: DateTime(2026, 1, 15),
      );

      final lines = csv.trim().split('\n');
      expect(lines.length, 2);
      expect(lines[1], contains('rec-001,m-100,"Oli Mesin",2026-01-10,5000'));
      expect(lines[1], contains('"Rutin service"'));
    });

    test('exportToCsv formats date accurately as YYYY-MM-DD', () {
      final record = MaintenanceRecord(
        id: 'rec-002',
        motorId: 'm-100',
        partType: 'Ban',
        lastReplacedAt: DateTime(2026, 12, 25),
        lastReplacedKilometer: 10000,
        notes: 'Ban luar',
        createdAt: DateTime(2026, 12, 25),
      );

      final csv = MaintenanceExportService.exportToCsv([record]);
      expect(csv, contains('2026-12-25'));
    });

    test('exportToCsv escapes quotes in notes properly', () {
      final record = MaintenanceRecord(
        id: 'rec-003',
        motorId: 'm-100',
        partType: 'Kampas Rem',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Diskon "50%" dari bengkel',
        createdAt: DateTime(2026, 1, 1),
      );

      final csv = MaintenanceExportService.exportToCsv([record]);
      expect(csv, contains('"Diskon ""50%"" dari bengkel"'));
    });

    test('exportToCsv includes estimated risk cost for warning status', () {
      final record = MaintenanceRecord(
        id: 'rec-004',
        motorId: 'm-100',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Warning km',
        createdAt: DateTime(2026, 1, 1),
      );

      // Oli Mesin interval 3000, at 12600 remaining is 400 (<600 = warning)
      final csv = MaintenanceExportService.exportToCsv(
        [record],
        motorKilometers: {'m-100': 12600},
        now: DateTime(2026, 1, 15),
      );

      // Warning status should include estimatedCostLater (2500000 for Oli Mesin)
      expect(csv, contains('warning,2500000'));
    });

    test('exportToCsv sets zero risk cost for safe status', () {
      final record = MaintenanceRecord(
        id: 'rec-005',
        motorId: 'm-100',
        partType: 'Ban',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Masih baru',
        createdAt: DateTime(2026, 1, 1),
      );

      // At 10500, safe status -> risk cost 0
      final csv = MaintenanceExportService.exportToCsv(
        [record],
        motorKilometers: {'m-100': 10500},
        now: DateTime(2026, 1, 15),
      );

      expect(csv, contains('safe,0'));
    });

    test('exportToCsv uses lastReplacedKilometer when motorId not in motorKilometers map', () {
      final record = MaintenanceRecord(
        id: 'rec-006',
        motorId: 'unknown-motor',
        partType: 'Aki',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 15000,
        notes: 'Aki GS',
        createdAt: DateTime(2026, 1, 1),
      );

      final csv = MaintenanceExportService.exportToCsv([record], motorKilometers: {});
      expect(csv, contains('rec-006,unknown-motor,"Aki"'));
    });

    test('exportToCsv exports multiple records on separate lines', () {
      final records = [
        MaintenanceRecord(
          id: 'rec-a',
          motorId: 'm-1',
          partType: 'Oli Mesin',
          lastReplacedAt: DateTime(2026, 1, 1),
          lastReplacedKilometer: 1000,
          notes: 'A',
          createdAt: DateTime(2026, 1, 1),
        ),
        MaintenanceRecord(
          id: 'rec-b',
          motorId: 'm-1',
          partType: 'V-Belt',
          lastReplacedAt: DateTime(2026, 1, 1),
          lastReplacedKilometer: 1000,
          notes: 'B',
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

      final csv = MaintenanceExportService.exportToCsv(records);
      final lines = csv.trim().split('\n');
      expect(lines.length, 3); // 1 header + 2 rows
    });

    test('generateSummary handles empty records list', () {
      final summary = MaintenanceExportService.generateSummary([]);
      expect(summary.totalRecords, 0);
      expect(summary.safeCount, 0);
      expect(summary.warningCount, 0);
      expect(summary.urgentCount, 0);
      expect(summary.totalEstimatedRiskCost, 0);
      expect(summary.partsNeedingAttention, isEmpty);
      expect(summary.isAllSafe, isFalse);
      expect(summary.hasUrgentParts, isFalse);
    });

    test('generateSummary counts safe records correctly', () {
      final records = [
        MaintenanceRecord(
          id: 'r-1',
          motorId: 'm-1',
          partType: 'Ban',
          lastReplacedAt: DateTime(2026, 1, 1),
          lastReplacedKilometer: 1000,
          notes: 'Baru',
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

      final summary = MaintenanceExportService.generateSummary(
        records,
        motorKilometers: {'m-1': 1100},
        now: DateTime(2026, 1, 15),
      );

      expect(summary.totalRecords, 1);
      expect(summary.safeCount, 1);
      expect(summary.warningCount, 0);
      expect(summary.urgentCount, 0);
      expect(summary.isAllSafe, isTrue);
      expect(summary.hasUrgentParts, isFalse);
    });

    test('generateSummary counts warning records and accumulates risk cost', () {
      final record = MaintenanceRecord(
        id: 'r-2',
        motorId: 'm-1',
        partType: 'Oli Mesin', // costLater = 2500000
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Warning',
        createdAt: DateTime(2026, 1, 1),
      );

      // Remaining 400 km <= 600 -> warning
      final summary = MaintenanceExportService.generateSummary(
        [record],
        motorKilometers: {'m-1': 12600},
        now: DateTime(2026, 1, 15),
      );

      expect(summary.warningCount, 1);
      expect(summary.totalEstimatedRiskCost, 2500000);
      expect(summary.partsNeedingAttention.length, 1);
    });

    test('generateSummary counts urgent records and marks hasUrgentParts', () {
      final record = MaintenanceRecord(
        id: 'r-3',
        motorId: 'm-1',
        partType: 'V-Belt', // costLater = 950000
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Urgent',
        createdAt: DateTime(2026, 1, 1),
      );

      // Exceeded by 1000 km -> urgent
      final summary = MaintenanceExportService.generateSummary(
        [record],
        motorKilometers: {'m-1': 35000},
        now: DateTime(2026, 1, 15),
      );

      expect(summary.urgentCount, 1);
      expect(summary.hasUrgentParts, isTrue);
      expect(summary.isAllSafe, isFalse);
      expect(summary.totalEstimatedRiskCost, 950000);
    });

    test('generateSummary combines multiple statuses and risk costs', () {
      final records = [
        MaintenanceRecord(
          id: 'r-safe',
          motorId: 'm-1',
          partType: 'Ban',
          lastReplacedAt: DateTime(2026, 1, 1),
          lastReplacedKilometer: 1000,
          notes: 'Safe',
          createdAt: DateTime(2026, 1, 1),
        ),
        MaintenanceRecord(
          id: 'r-urgent',
          motorId: 'm-1',
          partType: 'Oli Mesin', // 2500000
          lastReplacedAt: DateTime(2026, 1, 1),
          lastReplacedKilometer: 1000,
          notes: 'Urgent',
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

      final summary = MaintenanceExportService.generateSummary(
        records,
        motorKilometers: {'m-1': 5000},
        now: DateTime(2026, 1, 15),
      );

      expect(summary.totalRecords, 2);
      expect(summary.safeCount, 1);
      expect(summary.urgentCount, 1);
      expect(summary.partsNeedingAttention.length, 1);
      expect(summary.partsNeedingAttention.first.id, 'r-urgent');
      expect(summary.totalEstimatedRiskCost, 2500000);
    });

    test('generateSummary isAllSafe returns false when list has any warning', () {
      final record = MaintenanceRecord(
        id: 'r-warn',
        motorId: 'm-1',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 10000,
        notes: 'Warn',
        createdAt: DateTime(2026, 1, 1),
      );

      final summary = MaintenanceExportService.generateSummary(
        [record],
        motorKilometers: {'m-1': 12600},
        now: DateTime(2026, 1, 15),
      );

      expect(summary.isAllSafe, isFalse);
    });

    test('hasUrgentParts returns true when urgentCount is greater than zero', () {
      const summary = MaintenanceSummaryReport(
        totalRecords: 1,
        safeCount: 0,
        warningCount: 0,
        urgentCount: 1,
        totalEstimatedRiskCost: 500000,
        partsNeedingAttention: [],
      );
      expect(summary.hasUrgentParts, isTrue);
    });

    test('hasUrgentParts returns false when urgentCount is zero', () {
      const summary = MaintenanceSummaryReport(
        totalRecords: 1,
        safeCount: 1,
        warningCount: 0,
        urgentCount: 0,
        totalEstimatedRiskCost: 0,
        partsNeedingAttention: [],
      );
      expect(summary.hasUrgentParts, isFalse);
    });

    test('isAllSafe returns true only when totalRecords > 0 and no warning or urgent', () {
      const safeSummary = MaintenanceSummaryReport(
        totalRecords: 3,
        safeCount: 3,
        warningCount: 0,
        urgentCount: 0,
        totalEstimatedRiskCost: 0,
        partsNeedingAttention: [],
      );
      expect(safeSummary.isAllSafe, isTrue);
    });
  });
}
