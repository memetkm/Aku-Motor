import 'package:aku_motor/features/motors/data/shared_preferences_motor_repository.dart';
import 'package:aku_motor/features/motors/domain/motor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('CRUD tersimpan dan dapat dibaca repository baru', () async {
    final preferences = await SharedPreferences.getInstance();
    final firstSession = SharedPreferencesMotorRepository(preferences);
    final created = await firstSession.create(
      const MotorDraft(
        brand: 'Honda',
        model: 'Beat',
        year: 2023,
        currentKilometer: 5000,
      ),
    );

    final reopenedSession = SharedPreferencesMotorRepository(
      await SharedPreferences.getInstance(),
    );
    expect((await reopenedSession.getAll()).single.id, created.id);

    await reopenedSession.update(
      created.id,
      const MotorDraft(
        brand: 'Honda',
        model: 'Beat Street',
        year: 2023,
        currentKilometer: 6000,
      ),
    );
    expect((await reopenedSession.getAll()).single.model, 'Beat Street');

    await reopenedSession.delete(created.id);
    expect(await reopenedSession.getAll(), isEmpty);
  });
}
