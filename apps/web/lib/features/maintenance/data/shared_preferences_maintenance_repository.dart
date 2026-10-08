import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/maintenance_record.dart';
import '../domain/maintenance_repository.dart';

class SharedPreferencesMaintenanceRepository implements MaintenanceRepository {
  SharedPreferencesMaintenanceRepository(this._preferences);

  static const storageKey = 'aku_motor.maintenance.v1';
  final SharedPreferences _preferences;
  final _uuid = const Uuid();

  @override
  Future<List<MaintenanceRecord>> getAll() async {
    final raw = _preferences.getString(storageKey);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) =>
            MaintenanceRecord.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  @override
  Future<List<MaintenanceRecord>> getByMotorId(String motorId) async {
    final all = await getAll();
    return all.where((record) => record.motorId == motorId).toList();
  }

  @override
  Future<MaintenanceRecord> create(MaintenanceDraft draft) async {
    final items = (await getAll()).toList();
    final record = MaintenanceRecord(
      id: _uuid.v4(),
      motorId: draft.motorId,
      partType: draft.partType,
      lastReplacedAt: draft.lastReplacedAt,
      lastReplacedKilometer: draft.lastReplacedKilometer,
      notes: draft.notes,
      createdAt: DateTime.now(),
    );
    // Jika part sudah pernah dicatat untuk motor ini, perbarui rekaman yang lama
    final existingIndex = items.indexWhere(
      (r) => r.motorId == draft.motorId && r.partType == draft.partType,
    );
    if (existingIndex != -1) {
      items[existingIndex] = record;
    } else {
      items.insert(0, record);
    }
    await _persist(items);
    return record;
  }

  @override
  Future<MaintenanceRecord> update(String id, MaintenanceDraft draft) async {
    final items = (await getAll()).toList();
    final index = items.indexWhere((r) => r.id == id);
    if (index == -1) {
      throw StateError('Catatan servis tidak ditemukan.');
    }
    final updated = items[index].copyWith(
      motorId: draft.motorId,
      partType: draft.partType,
      lastReplacedAt: draft.lastReplacedAt,
      lastReplacedKilometer: draft.lastReplacedKilometer,
      notes: draft.notes,
    );
    items[index] = updated;
    await _persist(items);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    final items = (await getAll()).where((r) => r.id != id).toList();
    await _persist(items);
  }

  Future<void> _persist(List<MaintenanceRecord> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _preferences.setString(storageKey, encoded);
  }
}

