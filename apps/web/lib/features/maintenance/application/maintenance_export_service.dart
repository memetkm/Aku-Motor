import '../domain/maintenance_record.dart';
import '../domain/part_catalog.dart';

class MaintenanceSummaryReport {
  const MaintenanceSummaryReport({
    required this.totalRecords,
    required this.safeCount,
    required this.warningCount,
    required this.urgentCount,
    required this.totalEstimatedRiskCost,
    required this.partsNeedingAttention,
  });

  final int totalRecords;
  final int safeCount;
  final int warningCount;
  final int urgentCount;
  final int totalEstimatedRiskCost;
  final List<MaintenanceRecord> partsNeedingAttention;

  bool get hasUrgentParts => urgentCount > 0;
  bool get isAllSafe => totalRecords > 0 && warningCount == 0 && urgentCount == 0;
}

abstract final class MaintenanceExportService {
  static String exportToCsv(
    List<MaintenanceRecord> records, {
    Map<String, int>? motorKilometers,
    DateTime? now,
  }) {
    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln(
      'ID,MotorID,PartType,LastReplacedDate,LastReplacedKm,RemainingKm,RemainingDays,Status,EstimatedRiskCost,Notes',
    );

    for (final record in records) {
      final currentKm = motorKilometers?[record.motorId] ?? record.lastReplacedKilometer;
      final remainingKm = record.calculateRemainingKm(currentKm);
      final remainingDays = record.calculateRemainingDays(now: now);
      final status = record.calculateStatus(currentKm, now: now);
      final info = PartCatalog.getInfo(record.partType);
      final riskCost = status == MaintenanceStatus.safe ? 0 : info.estimatedCostLater;

      final escapedNotes = record.notes.replaceAll('"', '""');
      final dateStr = record.lastReplacedAt.toIso8601String().split('T').first;

      buffer.writeln(
        '${record.id},'
        '${record.motorId},'
        '"${record.partType}",'
        '$dateStr,'
        '${record.lastReplacedKilometer},'
        '$remainingKm,'
        '$remainingDays,'
        '${status.name},'
        '$riskCost,'
        '"$escapedNotes"',
      );
    }

    return buffer.toString();
  }

  static MaintenanceSummaryReport generateSummary(
    List<MaintenanceRecord> records, {
    Map<String, int>? motorKilometers,
    DateTime? now,
  }) {
    var safe = 0;
    var warning = 0;
    var urgent = 0;
    var totalRiskCost = 0;
    final attentionList = <MaintenanceRecord>[];

    for (final record in records) {
      final currentKm = motorKilometers?[record.motorId] ?? record.lastReplacedKilometer;
      final status = record.calculateStatus(currentKm, now: now);
      final info = PartCatalog.getInfo(record.partType);

      switch (status) {
        case MaintenanceStatus.safe:
          safe++;
          break;
        case MaintenanceStatus.warning:
          warning++;
          totalRiskCost += info.estimatedCostLater;
          attentionList.add(record);
          break;
        case MaintenanceStatus.urgent:
          urgent++;
          totalRiskCost += info.estimatedCostLater;
          attentionList.add(record);
          break;
      }
    }

    return MaintenanceSummaryReport(
      totalRecords: records.length,
      safeCount: safe,
      warningCount: warning,
      urgentCount: urgent,
      totalEstimatedRiskCost: totalRiskCost,
      partsNeedingAttention: attentionList,
    );
  }
}
