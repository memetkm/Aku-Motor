import 'app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getAll();
  Future<AppNotification> add(AppNotification notification);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> delete(String id);
  Future<void> clearAll();
}

