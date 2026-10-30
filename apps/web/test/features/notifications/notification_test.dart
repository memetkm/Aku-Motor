import 'package:aku_motor/features/maintenance/domain/maintenance_record.dart';
import 'package:aku_motor/features/motors/domain/motor.dart';
import 'package:aku_motor/features/notifications/application/notification_providers.dart';
import 'package:aku_motor/features/notifications/data/shared_preferences_notification_repository.dart';
import 'package:aku_motor/features/notifications/domain/app_notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Notifications - SharedPreferences & Notifier', () {
    test('Tambah notifikasi baru dan membaca dari persistence', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPreferencesNotificationRepository(prefs);

      final notif = await repo.add(
        AppNotification(
          id: 'notif-1',
          title: 'Uji Notifikasi',
          message: 'Pesan pengingat',
          type: NotificationType.warning,
          timestamp: DateTime.now(),
        ),
      );

      expect(notif.title, 'Uji Notifikasi');
      expect((await repo.getAll()).length, 1);

      // Reopened repo
      final reopenedRepo = SharedPreferencesNotificationRepository(
        await SharedPreferences.getInstance(),
      );
      final items = await reopenedRepo.getAll();
      expect(items.first.id, 'notif-1');
      expect(items.first.isRead, isFalse);

      // Mark as read
      await reopenedRepo.markAsRead('notif-1');
      expect((await reopenedRepo.getAll()).first.isRead, isTrue);

      // Delete
      await reopenedRepo.delete('notif-1');
      expect(await reopenedRepo.getAll(), isEmpty);
    });

    test('Izin Notifikasi dapat diminta dan ditolak dengan benar', () async {
      final prefs = await SharedPreferences.getInstance();
      final notifier = NotificationPermissionNotifier(prefs);

      expect(notifier.state, NotificationPermissionStatus.notDetermined);

      await notifier.requestPermission();
      expect(notifier.state, NotificationPermissionStatus.granted);

      await notifier.denyPermission();
      expect(notifier.state, NotificationPermissionStatus.denied);
    });

    test('Sinkronisasi otomatis membuat notifikasi saat part urgent atau warning', () async {
      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(
            InMemoryNotificationRepository(),
          ),
        ],
      );

      final notifier = container.read(notificationListProvider.notifier);
      await notifier.reload();

      final motor = Motor(
        id: 'motor-1',
        brand: 'Honda',
        model: 'Vario 160',
        year: 2024,
        currentKilometer: 10000,
        createdAt: DateTime(2026),
      );

      // Record Oli Mesin yang sudah lewat (limit 2000 + interval 2000 = 4000 km, sementara motor 10000 km -> URGENT)
      final record = MaintenanceRecord(
        id: 'rec-1',
        motorId: 'motor-1',
        partType: 'Oli Mesin',
        lastReplacedAt: DateTime(2026, 1, 1),
        lastReplacedKilometer: 2000,
        notes: '',
        createdAt: DateTime(2026),
      );

      await notifier.syncFromMaintenance([record], [motor]);

      final notifications = container.read(notificationListProvider).valueOrNull ?? [];
      expect(notifications.isNotEmpty, isTrue);
      expect(notifications.first.type, NotificationType.urgent);
      expect(notifications.first.partName, 'Oli Mesin');
    });
  });
}

