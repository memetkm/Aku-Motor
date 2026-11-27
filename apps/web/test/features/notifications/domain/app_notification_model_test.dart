import 'package:flutter_test/flutter_test.dart';
import 'package:aku_motor/features/notifications/domain/app_notification.dart';

void main() {
  group('AppNotification Domain Unit Tests', () {
    test('NotificationType enum values have labels and descriptions', () {
      expect(NotificationType.info.label, 'Info');
      expect(NotificationType.warning.label, 'Peringatan');
      expect(NotificationType.urgent.label, contains('Penting'));
      expect(NotificationType.booking.label, contains('Booking'));
      expect(NotificationType.info.description, isNotEmpty);
    });

    test('NotificationPermissionStatus enum has descriptive labels', () {
      expect(NotificationPermissionStatus.notDetermined.label, 'Belum Ditentukan');
      expect(NotificationPermissionStatus.granted.label, 'Diizinkan');
      expect(NotificationPermissionStatus.denied.label, 'Ditolak');
    });

    test('AppNotification copyWith updates isRead flag', () {
      final notif = AppNotification(
        id: 'n-1',
        title: 'Servis Oli',
        message: 'Saatnya ganti oli mesin.',
        type: NotificationType.warning,
        timestamp: DateTime(2026, 1, 1),
        isRead: false,
      );
      final updated = notif.copyWith(isRead: true);
      expect(updated.isRead, isTrue);
      expect(updated.id, 'n-1');
      expect(updated.title, 'Servis Oli');
    });

    test('AppNotification copyWith updates title and message', () {
      final notif = AppNotification(
        id: 'n-2',
        title: 'Judul Lama',
        message: 'Pesan Lama',
        type: NotificationType.info,
        timestamp: DateTime(2026, 1, 1),
      );
      final updated = notif.copyWith(
        title: 'Judul Baru',
        message: 'Pesan Baru',
      );
      expect(updated.title, 'Judul Baru');
      expect(updated.message, 'Pesan Baru');
      expect(updated.id, 'n-2');
    });

    test('AppNotification copyWith preserves fields when null', () {
      final notif = AppNotification(
        id: 'n-3',
        title: 'Judul',
        message: 'Pesan',
        type: NotificationType.urgent,
        timestamp: DateTime(2026, 1, 1),
        isRead: true,
        partName: 'Kampas Rem',
        route: '/maintenance',
      );
      final clone = notif.copyWith();
      expect(clone.id, notif.id);
      expect(clone.partName, notif.partName);
      expect(clone.route, notif.route);
      expect(clone.isRead, notif.isRead);
    });

    test('AppNotification toJson serializes all fields properly', () {
      final date = DateTime(2026, 2, 10, 15, 30);
      final notif = AppNotification(
        id: 'n-json',
        title: 'Notif JSON',
        message: 'Detail pesan',
        type: NotificationType.booking,
        timestamp: date,
        isRead: false,
        partName: 'Oli Mesin',
        route: '/bookings',
      );
      final json = notif.toJson();
      expect(json['id'], 'n-json');
      expect(json['type'], 'booking');
      expect(json['timestamp'], date.toIso8601String());
      expect(json['partName'], 'Oli Mesin');
      expect(json['route'], '/bookings');
    });

    test('AppNotification fromJson deserializes valid JSON', () {
      final json = {
        'id': 'n-parse',
        'title': 'Pengingat V-Belt',
        'message': 'KM mendekati 24.000',
        'type': 'warning',
        'timestamp': '2026-03-01T10:00:00.000',
        'isRead': true,
        'partName': 'V-Belt',
        'route': '/maintenance',
      };
      final notif = AppNotification.fromJson(json);
      expect(notif.id, 'n-parse');
      expect(notif.title, 'Pengingat V-Belt');
      expect(notif.type, NotificationType.warning);
      expect(notif.isRead, isTrue);
      expect(notif.partName, 'V-Belt');
    });

    test('AppNotification fromJson falls back to NotificationType.info on unknown type', () {
      final json = {
        'id': 'n-unknown',
        'title': 'Tipe Baru',
        'message': 'Halo',
        'type': 'mystery_type',
        'timestamp': '2026-03-01T10:00:00.000',
      };
      final notif = AppNotification.fromJson(json);
      expect(notif.type, NotificationType.info);
    });

    test('AppNotification fromJson defaults isRead to false when omitted', () {
      final json = {
        'id': 'n-unread',
        'title': 'Belum Dibaca',
        'message': 'Konten',
        'type': 'info',
        'timestamp': '2026-03-01T10:00:00.000',
      };
      final notif = AppNotification.fromJson(json);
      expect(notif.isRead, isFalse);
    });

    test('AppNotification supports optional partName', () {
      final notif = AppNotification(
        id: 'n-part',
        title: 'Part',
        message: 'Message',
        type: NotificationType.urgent,
        timestamp: DateTime(2026, 1, 1),
        partName: 'Aki',
      );
      expect(notif.partName, 'Aki');
    });

    test('AppNotification supports optional route', () {
      final notif = AppNotification(
        id: 'n-route',
        title: 'Route',
        message: 'Message',
        type: NotificationType.info,
        timestamp: DateTime(2026, 1, 1),
        route: '/nearby',
      );
      expect(notif.route, '/nearby');
    });

    test('sorting notifications list by timestamp descending puts newest first', () {
      final notifs = [
        AppNotification(
          id: '1',
          title: 'Old',
          message: 'Old',
          type: NotificationType.info,
          timestamp: DateTime(2026, 1, 1),
        ),
        AppNotification(
          id: '2',
          title: 'Newest',
          message: 'Newest',
          type: NotificationType.info,
          timestamp: DateTime(2026, 3, 1),
        ),
        AppNotification(
          id: '3',
          title: 'Middle',
          message: 'Middle',
          type: NotificationType.info,
          timestamp: DateTime(2026, 2, 1),
        ),
      ];

      notifs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      expect(notifs.first.id, '2');
      expect(notifs.last.id, '1');
    });

    test('filtering unread notifications returns only isRead == false', () {
      final notifs = [
        AppNotification(
          id: '1',
          title: 'Read',
          message: '',
          type: NotificationType.info,
          timestamp: DateTime(2026, 1, 1),
          isRead: true,
        ),
        AppNotification(
          id: '2',
          title: 'Unread',
          message: '',
          type: NotificationType.warning,
          timestamp: DateTime(2026, 1, 1),
          isRead: false,
        ),
      ];

      final unread = notifs.where((n) => !n.isRead).toList();
      expect(unread.length, 1);
      expect(unread.first.id, '2');
    });

    test('filtering notifications by NotificationType.urgent returns urgent only', () {
      final notifs = [
        AppNotification(
          id: '1',
          title: 'Info',
          message: '',
          type: NotificationType.info,
          timestamp: DateTime(2026, 1, 1),
        ),
        AppNotification(
          id: '2',
          title: 'Urgent',
          message: '',
          type: NotificationType.urgent,
          timestamp: DateTime(2026, 1, 1),
        ),
      ];

      final urgent = notifs.where((n) => n.type == NotificationType.urgent).toList();
      expect(urgent.length, 1);
      expect(urgent.first.id, '2');
    });

    test('toggling read state with copyWith inverts value', () {
      final unread = AppNotification(
        id: 'toggle',
        title: 'Toggle',
        message: 'Message',
        type: NotificationType.info,
        timestamp: DateTime(2026, 1, 1),
        isRead: false,
      );
      final read = unread.copyWith(isRead: !unread.isRead);
      expect(read.isRead, isTrue);
    });

    test('AppNotification default constructor has isRead false', () {
      final notif = AppNotification(
        id: 'default',
        title: 'Title',
        message: 'Message',
        type: NotificationType.info,
        timestamp: DateTime(2026, 1, 1),
      );
      expect(notif.isRead, isFalse);
    });
  });
}
