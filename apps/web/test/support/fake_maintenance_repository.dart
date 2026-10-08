import 'dart:async';

import 'package:aku_motor/features/maintenance/domain/maintenance_record.dart';
import 'package:aku_motor/features/maintenance/domain/maintenance_repository.dart';

class FakeMaintenanceRepository implements MaintenanceRepository {
  FakeMaintenanceRepository({
    List<MaintenanceRecord>? records,
    this.loadError,
    this.createCompleter,
  }) : _records = [...?records];

  final List<MaintenanceRecord> _records;
  Object? loadError;
  Completer<void>? createCompleter;
  int getAllCalls = 0;
  int createCalls = 0;

  @override
  Future<List<MaintenanceRecord>> getAll() async {
    getAllCalls++;
    if (loadError case final error?) throw error;
    return List.unmodifiable(_records);
  }

  @override
  Future<List<MaintenanceRecord>> getByMotorId(String motorId) async {
    final all = await getAll();
    return all.where((r) => r.motorId == motorId).toList();
  }

  @override
  Future<MaintenanceRecord> create(MaintenanceDraft draft) async {
    createCalls++;
    await createCompleter?.future;
    final record = MaintenanceRecord(
      id: 'm-$createCalls',
      motorId: draft.motorId,
      partType: draft.partType,
      lastReplacedAt: draft.lastReplacedAt,
      lastReplacedKilometer: draft.lastReplacedKilometer,
      notes: draft.notes,
      createdAt: DateTime(2026, 1, createCalls),
    );
    _records.add(record);
    return record;
  }

  @override
  Future<void> delete(String id) async {
    _records.removeWhere((r) => r.id == id);
  }

  @override
  Future<MaintenanceRecord> update(String id, MaintenanceDraft draft) async {
    final index = _records.indexWhere((r) => r.id == id);
    if (index == -1) throw StateError('Catatan servis tidak ditemukan.');
    final updated = _records[index].copyWith(
      motorId: draft.motorId,
      partType: draft.partType,
      lastReplacedAt: draft.lastReplacedAt,
      lastReplacedKilometer: draft.lastReplacedKilometer,
      notes: draft.notes,
    );
    _records[index] = updated;
    return updated;
  }
}

