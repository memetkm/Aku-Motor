import 'package:aku_motor/features/auth/data/shared_preferences_auth_repository.dart';
import 'package:aku_motor/features/auth/domain/profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProfileRepository Abstraction', () {
    test('getProfile mengembalikan data profil pengguna aktif', () async {
      final prefs = await SharedPreferences.getInstance();
      final authRepo = SharedPreferencesAuthRepository(prefs);
      final ProfileRepository profileRepo = authRepo;

      expect(await profileRepo.getProfile(), isNull);

      await authRepo.login(email: 'budi@akumotor.id', password: 'password123');

      final profile = await profileRepo.getProfile();
      expect(profile, isNotNull);
      expect(profile!.name, 'Budi Santoso');
      expect(profile.email, 'budi@akumotor.id');
    });

    test('updateProfile memperbarui profil melalui interface ProfileRepository', () async {
      final prefs = await SharedPreferences.getInstance();
      final authRepo = SharedPreferencesAuthRepository(prefs);
      final ProfileRepository profileRepo = authRepo;

      await authRepo.login(email: 'budi@akumotor.id', password: 'password123');

      final updated = await profileRepo.updateProfile(
        name: 'Budi Santoso, M.Kom.',
        phoneNumber: '081299887766',
      );

      expect(updated.name, 'Budi Santoso, M.Kom.');
      expect(updated.phoneNumber, '081299887766');

      final verified = await profileRepo.getProfile();
      expect(verified?.name, 'Budi Santoso, M.Kom.');
      expect(verified?.phoneNumber, '081299887766');
    });
  });
}
