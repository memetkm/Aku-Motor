import 'package:aku_motor/features/maintenance/data/shared_preferences_maintenance_repository.dart';
import 'package:aku_motor/features/maintenance/domain/maintenance_record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('CRUD catatan servis part tersimpan dan persisten', () async {
    final preferences = await SharedPreferences.getInstance();
    final firstSession = SharedPreferencesMaintenanceRepository(preferences);
    final created = await firstSession.create(
      MaintenanceDraft(
        motorId: 'motor-1',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 9, 1),
        lastReplacedKilometer: 5000,
        notes: 'Oli MPX2 0.8L',
      ),
    );

    final reopenedSession = SharedPreferencesMaintenanceRepository(
      await SharedPreferences.getInstance(),
    );
    expect((await reopenedSession.getAll()).single.id, created.id);
    expect((await reopenedSession.getAll()).single.partType, 'Oli Mesin');
    expect((await reopenedSession.getAll()).single.lastReplacedKilometer, 5000);

    await reopenedSession.update(
      created.id,
      MaintenanceDraft(
        motorId: 'motor-1',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 10, 1),
        lastReplacedKilometer: 7500,
        notes: 'Oli Shell Advance 10W-40',
      ),
    );
    expect((await reopenedSession.getAll()).single.lastReplacedKilometer, 7500);

    await reopenedSession.delete(created.id);
    expect(await reopenedSession.getAll(), isEmpty);
  });
}

