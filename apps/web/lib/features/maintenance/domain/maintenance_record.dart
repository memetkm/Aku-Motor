import 'part_catalog.dart';

enum MaintenanceStatus {
  safe('Aman', 'Kondisi masih dalam batas pemakaian normal.'),
  warning('Perhatian', 'Mendekati jadwal penggantian, segera rencanakan servis.'),
  urgent('Ganti Segera', 'Sudah melewati batas rekomendasi! Bahaya jika ditunda.');

  const MaintenanceStatus(this.label, this.description);
  final String label;
  final String description;
}

class MaintenanceRecord {
  const MaintenanceRecord({
    required this.id,
    required this.motorId,
    required this.partType,
    required this.lastReplacedAt,
    required this.lastReplacedKilometer,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final String motorId;
  final String partType;
  final DateTime lastReplacedAt;
  final int lastReplacedKilometer;
  final String notes;
  final DateTime createdAt;

  int calculateRemainingKm(int currentKilometer) {
    final info = PartCatalog.getInfo(partType);
    final limit = lastReplacedKilometer + info.intervalKilometer;
    return limit - currentKilometer;
  }

  int calculateRemainingDays({DateTime? now}) {
    final current = now ?? DateTime.now();
    final info = PartCatalog.getInfo(partType);
    final due = DateTime(
      lastReplacedAt.year,
      lastReplacedAt.month + info.intervalMonth,
      lastReplacedAt.day,
    );
    return due.difference(current).inDays;
  }

  MaintenanceStatus calculateStatus(int currentKilometer, {DateTime? now}) {
    final info = PartCatalog.getInfo(partType);
    final remainingKm = calculateRemainingKm(currentKilometer);
    final remainingDays = calculateRemainingDays(now: now);

    if (remainingKm <= 0 || remainingDays <= 0) {
      return MaintenanceStatus.urgent;
    }
    if (remainingKm <= (info.intervalKilometer * 0.2).round() || remainingDays <= 14) {
      return MaintenanceStatus.warning;
    }
    return MaintenanceStatus.safe;
  }

  MaintenanceRecord copyWith({
    String? id,
    String? motorId,
    String? partType,
    DateTime? lastReplacedAt,
    int? lastReplacedKilometer,
    String? notes,
    DateTime? createdAt,
  }) {
    return MaintenanceRecord(
      id: id ?? this.id,
      motorId: motorId ?? this.motorId,
      partType: partType ?? this.partType,
      lastReplacedAt: lastReplacedAt ?? this.lastReplacedAt,
      lastReplacedKilometer: lastReplacedKilometer ?? this.lastReplacedKilometer,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'motorId': motorId,
        'partType': partType,
        'lastReplacedAt': lastReplacedAt.toIso8601String(),
        'lastReplacedKilometer': lastReplacedKilometer,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) =>
      MaintenanceRecord(
        id: json['id'] as String,
        motorId: json['motorId'] as String,
        partType: json['partType'] as String,
        lastReplacedAt: DateTime.parse(json['lastReplacedAt'] as String),
        lastReplacedKilometer: json['lastReplacedKilometer'] as int,
        notes: json['notes'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class MaintenanceDraft {
  const MaintenanceDraft({
    required this.motorId,
    required this.partType,
    required this.lastReplacedAt,
    required this.lastReplacedKilometer,
    this.notes = '',
  });

  final String motorId;
  final String partType;
  final DateTime lastReplacedAt;
  final int lastReplacedKilometer;
  final String notes;
}

