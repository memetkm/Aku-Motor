import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/app_notification.dart';
import '../domain/notification_repository.dart';

class SharedPreferencesNotificationRepository implements NotificationRepository {
  SharedPreferencesNotificationRepository(
    this._preferences, {
    Uuid uuid = const Uuid(),
  }) : _uuid = uuid;

  static const storageKey = 'aku_motor.notifications.v1';
  final SharedPreferences _preferences;
  final Uuid _uuid;

  @override
  Future<List<AppNotification>> getAll() async {
    final raw = _preferences.getString(storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      final list = decoded
          .map((item) => AppNotification.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
      // sort latest first
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<AppNotification> add(AppNotification notification) async {
    final list = await getAll();
    final toAdd = notification.id.isEmpty
        ? notification.copyWith(id: _uuid.v4())
        : notification;
    list.insert(0, toAdd);
    await _save(list);
    return toAdd;
  }

  @override
  Future<void> markAsRead(String id) async {
    final list = await getAll();
    final index = list.indexWhere((n) => n.id == id);
    if (index != -1) {
      list[index] = list[index].copyWith(isRead: true);
      await _save(list);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final list = await getAll();
    final updated = list.map((n) => n.copyWith(isRead: true)).toList();
    await _save(updated);
  }

  @override
  Future<void> delete(String id) async {
    final list = await getAll();
    list.removeWhere((n) => n.id == id);
    await _save(list);
  }

  @override
  Future<void> clearAll() async {
    await _preferences.remove(storageKey);
  }

  Future<void> _save(List<AppNotification> list) async {
    final encoded = jsonEncode(list.map((n) => n.toJson()).toList());
    await _preferences.setString(storageKey, encoded);
  }
}

