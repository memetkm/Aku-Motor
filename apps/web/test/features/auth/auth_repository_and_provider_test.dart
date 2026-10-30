import 'package:aku_motor/features/auth/data/shared_preferences_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Auth - SharedPreferencesAuthRepository', () {
    test('Login dengan akun demo Budi berhasil dan menyimpan sesi', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPreferencesAuthRepository(prefs);

      expect(await repo.getCurrentUser(), isNull);

      final user = await repo.login(
        email: 'budi@akumotor.id',
        password: 'password123',
      );

      expect(user.email, 'budi@akumotor.id');
      expect(user.name, 'Budi Santoso');
      expect(user.isGuest, isFalse);

      // Verifikasi sesi tersimpan di storage
      final sessionRepo = SharedPreferencesAuthRepository(
        await SharedPreferences.getInstance(),
      );
      final current = await sessionRepo.getCurrentUser();
      expect(current, isNotNull);
      expect(current!.name, 'Budi Santoso');
    });

    test('Login dengan kredensial salah melempar FormatException', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPreferencesAuthRepository(prefs);

      expect(
        () => repo.login(email: 'salah@akumotor.id', password: 'wrongpassword'),
        throwsA(isA<FormatException>()),
      );
    });

    test('Daftar akun baru berhasil dan dapat login kembali', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPreferencesAuthRepository(prefs);

      final registered = await repo.register(
        name: 'Matthew Keane',
        email: 'matthew@student.pradita.ac.id',
        password: 'secretpassword',
        phoneNumber: '081122334455',
      );

      expect(registered.name, 'Matthew Keane');
      expect(registered.email, 'matthew@student.pradita.ac.id');

      // Logout
      await repo.logout();
      expect(await repo.getCurrentUser(), isNull);

      // Login ulang dengan akun yang baru didaftarkan
      final loggedIn = await repo.login(
        email: 'matthew@student.pradita.ac.id',
        password: 'secretpassword',
      );
      expect(loggedIn.id, registered.id);
      expect(loggedIn.name, 'Matthew Keane');
    });

    test('Masuk sebagai tamu (Guest Mode) berhasil', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPreferencesAuthRepository(prefs);

      final guest = await repo.loginAsGuest();
      expect(guest.isGuest, isTrue);
      expect(guest.name, 'Pengendara Tamu');

      final current = await repo.getCurrentUser();
      expect(current?.isGuest, isTrue);
    });

    test('Update profile memperbarui nama dan nomor telepon', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPreferencesAuthRepository(prefs);

      await repo.login(
        email: 'budi@akumotor.id',
        password: 'password123',
      );

      final updated = await repo.updateProfile(
        name: 'Budi Santoso S.T.',
        phoneNumber: '089988776655',
      );

      expect(updated.name, 'Budi Santoso S.T.');
      expect(updated.phoneNumber, '089988776655');

      final reloaded = await repo.getCurrentUser();
      expect(reloaded?.name, 'Budi Santoso S.T.');
    });
  });
}

