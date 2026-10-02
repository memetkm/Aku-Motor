import 'motor.dart';

abstract interface class MotorRepository {
  Future<List<Motor>> getAll();
  Future<Motor> create(MotorDraft draft);
  Future<Motor> update(String id, MotorDraft draft);
  Future<void> delete(String id);
}
