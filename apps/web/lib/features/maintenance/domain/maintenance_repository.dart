import 'maintenance_record.dart';

abstract interface class MaintenanceRepository {
  Future<List<MaintenanceRecord>> getAll();
  Future<List<MaintenanceRecord>> getByMotorId(String motorId);
  Future<MaintenanceRecord> create(MaintenanceDraft draft);
  Future<MaintenanceRecord> update(String id, MaintenanceDraft draft);
  Future<void> delete(String id);
}

