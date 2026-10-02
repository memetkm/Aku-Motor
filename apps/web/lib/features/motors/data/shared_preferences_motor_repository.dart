import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/motor.dart';
import '../domain/motor_repository.dart';

class SharedPreferencesMotorRepository implements MotorRepository {
  SharedPreferencesMotorRepository(this._preferences, {Uuid uuid = const Uuid()})
      : _uuid = uuid;

  static const storageKey = 'aku_motor.motors.v1';
  final SharedPreferences _preferences;
  final Uuid _uuid;

  @override
  Future<List<Motor>> getAll() async {
    final value = _preferences.getString(storageKey);
    if (value == null || value.isEmpty) return [];

    final decoded = jsonDecode(value);
    if (decoded is! List) throw const FormatException('Data motor lokal rusak.');
    return decoded
        .map((item) => Motor.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Motor> create(MotorDraft draft) async {
    final items = await getAll();
    final motor = Motor(
      id: _uuid.v4(),
      brand: draft.brand,
      model: draft.model,
      year: draft.year,
      currentKilometer: draft.currentKilometer,
      createdAt: DateTime.now(),
    );
    await _save([...items, motor]);
    return motor;
  }

  @override
  Future<Motor> update(String id, MotorDraft draft) async {
    final items = await getAll();
    final index = items.indexWhere((motor) => motor.id == id);
    if (index == -1) throw StateError('Motor tidak ditemukan.');
    final updated = items[index].copyWith(
      brand: draft.brand,
      model: draft.model,
      year: draft.year,
      currentKilometer: draft.currentKilometer,
    );
    items[index] = updated;
    await _save(items);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    final items = await getAll();
    await _save(items.where((motor) => motor.id != id).toList());
  }

  Future<void> _save(List<Motor> items) async {
    final encoded = jsonEncode(items.map((motor) => motor.toJson()).toList());
    final didSave = await _preferences.setString(storageKey, encoded);
    if (!didSave) throw StateError('Data motor gagal disimpan.');
  }
}
