import 'package:aku_motor/features/notifications/application/notification_providers.dart';
import 'package:aku_motor/features/notifications/domain/app_notification.dart';
import 'package:aku_motor/features/notifications/presentation/notification_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NotificationListScreen menampilkan item notifikasi dan banner izin', (tester) async {
    final repo = InMemoryNotificationRepository();
    await repo.add(
      AppNotification(
        id: 'notif-demo-1',
        title: '⚠️ Pengingat Oli Mesin',
        message: 'Ganti oli mesin sebelum 200 km lagi.',
        type: NotificationType.warning,
        timestamp: DateTime.now(),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(
          home: NotificationListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notifikasi & Pengingat'), findsOneWidget);
    expect(find.text('⚠️ Pengingat Oli Mesin'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Belum Dibaca'), findsOneWidget);
  });
}

