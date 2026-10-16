import 'package:aku_motor/app.dart';
import 'package:aku_motor/features/motors/application/motor_providers.dart';
import 'package:aku_motor/features/motors/data/shared_preferences_motor_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'Alur Vertikal FE -> Local Storage: CRUD tersimpan setelah restart/reopen',
    (tester) async {
      // ---------------------------------------------------------------
      // 1. SESSION PERTAMA: BUKA APLIKASI
      // ---------------------------------------------------------------
      final preferences = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
          child: const AkuMotorApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Dari Dashboard, navigasi ke halaman Kelola Motor
      await tester.tap(find.text('Kelola motor'));
      await tester.pumpAndSettle();

      // Memastikan kondisi awal: empty state
      expect(find.text('Belum ada motor'), findsOneWidget);

      // ---------------------------------------------------------------
      // C - CREATE: Tambah motor baru melalui UI Form Dialog
      // ---------------------------------------------------------------
      await tester.tap(find.byKey(const Key('addMotorButton')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('brandField')), 'Yamaha');
      await tester.enterText(find.byKey(const Key('modelField')), 'NMAX 155');
      await tester.enterText(find.byKey(const Key('yearField')), '2024');
      await tester.enterText(find.byKey(const Key('kilometerField')), '15000');
      await tester.tap(find.byKey(const Key('submitMotorButton')));
      await tester.pumpAndSettle();

      // ---------------------------------------------------------------
      // R - READ (Session 1): Motor tampil di UI
      // ---------------------------------------------------------------
      expect(find.text('Yamaha NMAX 155'), findsOneWidget);
      expect(find.text('2024 • 15000 km'), findsOneWidget);

      // ---------------------------------------------------------------
      // PERSISTENCE TEST: SIMULASI APLIKASI DITUTUP & DIBUKA KEMBALI
      // ---------------------------------------------------------------
      // Mengganti widget tree dan session baru namun membaca storage yang sama
      final reopenedPreferences = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(reopenedPreferences),
          ],
          child: const AkuMotorApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigasi kembali ke Kelola Motor
      await tester.tap(find.text('Kelola motor'));
      await tester.pumpAndSettle();

      // VERIFIKASI DATA TETAP TERSEDIA DARI LOCAL STORAGE
      expect(find.text('Yamaha NMAX 155'), findsOneWidget);
      expect(find.text('2024 • 15000 km'), findsOneWidget);

      // ---------------------------------------------------------------
      // U - UPDATE: Edit motor
      // ---------------------------------------------------------------
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('modelField')), 'NMAX Turbo');
      await tester.enterText(find.byKey(const Key('kilometerField')), '16500');
      await tester.tap(find.byKey(const Key('submitMotorButton')));
      await tester.pumpAndSettle();

      expect(find.text('Yamaha NMAX Turbo'), findsOneWidget);
      expect(find.text('2024 • 16500 km'), findsOneWidget);

      // ---------------------------------------------------------------
      // D - DELETE: Hapus motor
      // ---------------------------------------------------------------
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // Konfirmasi dialog hapus
      await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
      await tester.pumpAndSettle();

      // Verifikasi UI kembali ke empty state
      expect(find.text('Belum ada motor'), findsOneWidget);

      // Verifikasi isi local storage kosong
      final thirdPreferences = await SharedPreferences.getInstance();
      expect(
        thirdPreferences.getString(SharedPreferencesMotorRepository.storageKey),
        '[]',
      );
    },
  );
}

