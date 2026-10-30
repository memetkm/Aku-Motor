import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../maintenance/domain/maintenance_record.dart';
import '../../motors/application/motor_providers.dart';
import '../../motors/domain/motor.dart';
import '../data/shared_preferences_notification_repository.dart';
import '../domain/app_notification.dart';
import '../domain/notification_repository.dart';

const kNotificationPermissionKey = 'aku_motor.notification_permission.v1';

class InMemoryNotificationRepository implements NotificationRepository {
  final List<AppNotification> _items = [];

  @override
  Future<List<AppNotification>> getAll() async => List.unmodifiable(_items);

  @override
  Future<AppNotification> add(AppNotification notification) async {
    final toAdd = notification.id.isEmpty
        ? notification.copyWith(id: DateTime.now().microsecondsSinceEpoch.toString())
        : notification;
    _items.insert(0, toAdd);
    return toAdd;
  }

  @override
  Future<void> markAsRead(String id) async {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx != -1) _items[idx] = _items[idx].copyWith(isRead: true);
  }

  @override
  Future<void> markAllAsRead() async {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((n) => n.id == id);
  }

  @override
  Future<void> clearAll() async {
    _items.clear();
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) {
    try {
      final prefs = ref.watch(sharedPreferencesProvider);
      return SharedPreferencesNotificationRepository(prefs);
    } catch (_) {
      return InMemoryNotificationRepository();
    }
  },
);

final notificationPermissionProvider =
    StateNotifierProvider<NotificationPermissionNotifier, NotificationPermissionStatus>(
  (ref) {
    try {
      final prefs = ref.watch(sharedPreferencesProvider);
      return NotificationPermissionNotifier(prefs);
    } catch (_) {
      return NotificationPermissionNotifier(null);
    }
  },
);

class NotificationPermissionNotifier
    extends StateNotifier<NotificationPermissionStatus> {
  NotificationPermissionNotifier(this._preferences)
      : super(_loadInitial(_preferences));

  final SharedPreferences? _preferences;

  static NotificationPermissionStatus _loadInitial(SharedPreferences? prefs) {
    if (prefs == null) return NotificationPermissionStatus.notDetermined;
    final saved = prefs.getString(kNotificationPermissionKey);
    if (saved == NotificationPermissionStatus.granted.name) {
      return NotificationPermissionStatus.granted;
    }
    if (saved == NotificationPermissionStatus.denied.name) {
      return NotificationPermissionStatus.denied;
    }
    return NotificationPermissionStatus.notDetermined;
  }

  Future<void> requestPermission() async {
    state = NotificationPermissionStatus.granted;
    await _preferences?.setString(kNotificationPermissionKey, state.name);
  }

  Future<void> denyPermission() async {
    state = NotificationPermissionStatus.denied;
    await _preferences?.setString(kNotificationPermissionKey, state.name);
  }

  Future<void> resetPermission() async {
    state = NotificationPermissionStatus.notDetermined;
    await _preferences?.remove(kNotificationPermissionKey);
  }
}

final notificationListProvider =
    AsyncNotifierProvider<NotificationListNotifier, List<AppNotification>>(
  NotificationListNotifier.new,
);

class NotificationListNotifier extends AsyncNotifier<List<AppNotification>> {
  NotificationRepository get _repository => ref.read(notificationRepositoryProvider);

  @override
  Future<List<AppNotification>> build() => _repository.getAll();

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getAll);
  }

  Future<void> add(AppNotification notification) async {
    await _repository.add(notification);
    state = AsyncData(await _repository.getAll());
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    state = AsyncData(await _repository.getAll());
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    state = AsyncData(await _repository.getAll());
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    state = AsyncData(await _repository.getAll());
  }

  Future<void> clearAll() async {
    await _repository.clearAll();
    state = const AsyncData([]);
  }

  Future<void> triggerSimulatedReminder() async {
    final sample = AppNotification(
      id: '',
      title: '⚠️ Pengingat Servis: Waktunya Ganti Oli Mesin',
      message:
          'Jarak tempuh motor Anda sudah mendekati batas rekomendasi. Segera ganti oli mesin untuk menjaga performa.',
      type: NotificationType.warning,
      timestamp: DateTime.now(),
      partName: 'Oli Mesin',
      route: '/maintenance',
    );
    await add(sample);
  }

  Future<void> syncFromMaintenance(
    List<MaintenanceRecord> records,
    List<Motor> motors,
  ) async {
    final currentList = state.valueOrNull ?? [];
    for (final record in records) {
      final motor = motors.cast<Motor?>().firstWhere(
            (m) => m?.id == record.motorId,
            orElse: () => null,
          );
      final currentKm = motor?.currentKilometer ?? record.lastReplacedKilometer;
      final status = record.calculateStatus(currentKm);

      if (status == MaintenanceStatus.urgent || status == MaintenanceStatus.warning) {
        final remainingKm = record.calculateRemainingKm(currentKm);
        final title = status == MaintenanceStatus.urgent
            ? '🚨 Segera Ganti ${record.partType}!'
            : '⚠️ Perhatian: ${record.partType} Mendekati Batas';
        final message = status == MaintenanceStatus.urgent
            ? 'Komponen ${record.partType} sudah melewati batas interval ($remainingKm km). Bahaya jika ditunda!'
            : 'Sisa jarak tempuh untuk ${record.partType} tinggal $remainingKm km. Rencanakan servis segera.';

        final alreadyExists = currentList.any(
          (n) => n.partName == record.partType && n.title == title,
        );

        if (!alreadyExists) {
          await add(
            AppNotification(
              id: '',
              title: title,
              message: message,
              type: status == MaintenanceStatus.urgent
                  ? NotificationType.urgent
                  : NotificationType.warning,
              timestamp: DateTime.now(),
              partName: record.partType,
              route: '/maintenance',
            ),
          );
        }
      }
    }
  }
}

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationListProvider).valueOrNull ?? [];
  return notifications.where((n) => !n.isRead).length;
});

