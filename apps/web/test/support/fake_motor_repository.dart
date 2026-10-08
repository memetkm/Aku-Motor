import 'dart:async';

import 'package:aku_motor/features/motors/domain/motor.dart';
import 'package:aku_motor/features/motors/domain/motor_repository.dart';

class FakeMotorRepository implements MotorRepository {
  FakeMotorRepository({List<Motor>? motors, this.loadError, this.createCompleter})
      : _motors = [...?motors];

  final List<Motor> _motors;
  Object? loadError;
  Completer<void>? createCompleter;
  int getAllCalls = 0;
  int createCalls = 0;

  @override
  Future<List<Motor>> getAll() async {
    getAllCalls++;
    if (loadError case final error?) throw error;
    return List.unmodifiable(_motors);
  }

  @override
  Future<Motor> create(MotorDraft draft) async {
    createCalls++;
    await createCompleter?.future;
    final motor = Motor(
      id: 'motor-$createCalls',
      brand: draft.brand,
      model: draft.model,
      year: draft.year,
      currentKilometer: draft.currentKilometer,
      createdAt: DateTime(2026, 1, createCalls),
    );
    _motors.add(motor);
    return motor;
  }

  @override
  Future<void> delete(String id) async {
    _motors.removeWhere((motor) => motor.id == id);
  }

  @override
  Future<Motor> update(String id, MotorDraft draft) async {
    final index = _motors.indexWhere((motor) => motor.id == id);
    if (index == -1) throw StateError('Motor tidak ditemukan.');
    final motor = _motors[index].copyWith(
      brand: draft.brand,
      model: draft.model,
      year: draft.year,
      currentKilometer: draft.currentKilometer,
    );
    _motors[index] = motor;
    return motor;
  }
}
