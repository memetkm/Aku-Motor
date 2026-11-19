import 'package:aku_motor/core/logging/app_logger.dart';
import 'package:aku_motor/core/logging/log_entry.dart';
import 'package:aku_motor/core/logging/presentation/log_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await AppLogger.instance.clear();
  });

  group('AppLogger Core & System Tracing', () {
    test('mencatat berbagai tingkat log (info, debug, warning, error)', () {
      AppLogger.instance.i('Aplikasi dibuka', tag: 'AUTH');
      AppLogger.instance.d('Fetching status motor', tag: 'MOTOR');
      AppLogger.instance.w('Koneksi lambat terdeteksi', tag: 'NETWORK');
      AppLogger.instance.e(
        'Database query gagal',
        tag: 'STORAGE',
        error: 'TimeoutException',
      );

      final logs = AppLogger.instance.logs;
      expect(logs.length, 5); // 1 dari clear ("Seluruh riwayat log dibersihkan") + 4 baru

      final errorLog = logs.firstWhere((l) => l.level == LogLevel.error);
      expect(errorLog.tag, 'STORAGE');
      expect(errorLog.message, 'Database query gagal');
      expect(errorLog.error, 'TimeoutException');
    });

    test('toFormattedString memformat log dengan format timestamp, tag, dan level', () {
      final entry = LogEntry(
        timestamp: DateTime(2026, 11, 19, 14, 30, 0),
        level: LogLevel.warning,
        tag: 'GPS',
        message: 'Akurasi rendah',
        error: 'GpsSignalLost',
      );

      final formatted = entry.toFormattedString();
      expect(formatted, contains('[14:30:00.000]'));
      expect(formatted, contains('[WARN]'));
      expect(formatted, contains('[GPS] Akurasi rendah'));
      expect(formatted, contains('Error: GpsSignalLost'));
    });

    test('exportLogsAsText menghasilkan laporan diagnostik lengkap', () {
      AppLogger.instance.i('Layanan aktif', tag: 'INIT');
      final export = AppLogger.instance.exportLogsAsText();

      expect(export, contains('AKU MOTOR SYSTEM DIAGNOSTIC LOG'));
      expect(export, contains('[INIT] Layanan aktif'));
    });

    test('clear menghapus seluruh catatan log', () async {
      AppLogger.instance.i('Catatan 1', tag: 'TEST');
      AppLogger.instance.i('Catatan 2', tag: 'TEST');
      expect(AppLogger.instance.logs.isNotEmpty, isTrue);

      await AppLogger.instance.clear();
      // Setelah clear, hanya tersisa 1 log info sistem pembersihan
      expect(AppLogger.instance.logs.length, 1);
      expect(AppLogger.instance.logs.first.message, 'Seluruh riwayat log dibersihkan.');
    });
  });

  group('LogViewerScreen Widget Test', () {
    testWidgets('LogViewerScreen merender daftar log, filter, dan fungsi pencarian', (tester) async {
      await AppLogger.instance.clear();
      AppLogger.instance.i('Pengguna berhasil login', tag: 'AUTH');
      AppLogger.instance.e('Gagal memperbarui odometer', tag: 'MOTOR', error: 'DbError');

      await tester.pumpWidget(
        const MaterialApp(
          home: LogViewerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Log Sistem (Tracing)'), findsOneWidget);
      expect(find.byKey(const Key('copyLogsButton')), findsOneWidget);
      expect(find.byKey(const Key('simulateErrorButton')), findsOneWidget);
      expect(find.byKey(const Key('clearLogsButton')), findsOneWidget);
      expect(find.byKey(const Key('logSearchField')), findsOneWidget);

      expect(find.text('Pengguna berhasil login'), findsOneWidget);
      expect(find.text('Gagal memperbarui odometer'), findsOneWidget);

      // Coba filter pencarian "odometer"
      await tester.enterText(find.byKey(const Key('logSearchField')), 'odometer');
      await tester.pumpAndSettle();

      expect(find.text('Gagal memperbarui odometer'), findsOneWidget);
      expect(find.text('Pengguna berhasil login'), findsNothing);

      // Simulasi error log melalui tombol aksi
      await tester.tap(find.byKey(const Key('simulateErrorButton')));
      await tester.pumpAndSettle();

      expect(find.text('Simulasi error berhasil dicatat ke log!'), findsOneWidget);
    });
  });
}
