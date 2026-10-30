import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../application/notification_providers.dart';
import '../domain/app_notification.dart';

class NotificationListScreen extends ConsumerStatefulWidget {
  const NotificationListScreen({super.key});

  static const routeName = '/notifications';

  @override
  ConsumerState<NotificationListScreen> createState() =>
      _NotificationListScreenState();
}

class _NotificationListScreenState
    extends ConsumerState<NotificationListScreen> {
  bool _filterOnlyUnread = false;

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationListProvider);
    final permission = ref.watch(notificationPermissionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi & Pengingat'),
        actions: [
          IconButton(
            tooltip: 'Simulasikan Pengingat Servis',
            icon: const Icon(Icons.add_alert_outlined),
            onPressed: () async {
              await ref
                  .read(notificationListProvider.notifier)
                  .triggerSimulatedReminder();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifikasi simulasi berhasil dikirim!'),
                  ),
                );
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'read_all') {
                await ref
                    .read(notificationListProvider.notifier)
                    .markAllAsRead();
              } else if (value == 'clear_all') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus Semua Notifikasi?'),
                    content: const Text(
                      'Semua riwayat notifikasi akan dihapus secara permanen.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Batal'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref.read(notificationListProvider.notifier).clearAll();
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'read_all',
                child: Row(
                  children: [
                    Icon(Icons.done_all, size: 20),
                    SizedBox(width: 8),
                    Text('Tandai semua dibaca'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Hapus semua'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Permission Status Banner
          _buildPermissionBanner(context, permission),

          // 2. Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: !_filterOnlyUnread,
                  onSelected: (val) {
                    if (val) setState(() => _filterOnlyUnread = false);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Belum Dibaca'),
                  selected: _filterOnlyUnread,
                  onSelected: (val) {
                    if (val) setState(() => _filterOnlyUnread = true);
                  },
                ),
              ],
            ),
          ),

          // 3. Main Content
          Expanded(
            child: notificationsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(key: Key('notificationLoading')),
              ),
              error: (err, _) => ErrorState(
                message: err.toString(),
                onRetry: () =>
                    ref.read(notificationListProvider.notifier).reload(),
              ),
              data: (list) {
                final filtered = _filterOnlyUnread
                    ? list.where((n) => !n.isRead).toList()
                    : list;

                if (filtered.isEmpty) {
                  return EmptyState(
                    title: _filterOnlyUnread
                        ? 'Tidak ada notifikasi belum dibaca'
                        : 'Belum ada notifikasi',
                    message:
                        'Pengingat otomatis akan muncul di sini saat motor Anda mendekati batas servis komponen penting.',
                    icon: Icons.notifications_none_outlined,
                    actionLabel: 'Simulasi Pengingat Baru',
                    onAction: () => ref
                        .read(notificationListProvider.notifier)
                        .triggerSimulatedReminder(),
                  );
                }

                return ListView.separated(
                  key: const Key('notificationList'),
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _NotificationTile(
                      notification: item,
                      onTap: () async {
                        if (!item.isRead) {
                          await ref
                              .read(notificationListProvider.notifier)
                              .markAsRead(item.id);
                        }
                        if (item.route != null && context.mounted) {
                          Navigator.pushNamed(context, item.route!);
                        }
                      },
                      onDelete: () => ref
                          .read(notificationListProvider.notifier)
                          .delete(item.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionBanner(
    BuildContext context,
    NotificationPermissionStatus status,
  ) {
    if (status == NotificationPermissionStatus.granted) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green.shade800, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Izin notifikasi aktif. Peringatan servis akan disampaikan tepat waktu.',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ],
        ),
      );
    }

    if (status == NotificationPermissionStatus.denied) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.notifications_off_outlined,
                color: Colors.amber.shade900, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Izin Notifikasi Dimatikan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Text(
                    'Anda berisiko melewatkan info oli aus atau kampas rem tipis.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: () => ref
                  .read(notificationPermissionProvider.notifier)
                  .requestPermission(),
              child: const Text('Aktifkan'),
            ),
          ],
        ),
      );
    }

    // notDetermined
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active_outlined,
              color: Colors.blue.shade900, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aktifkan Notifikasi Servis',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const Text(
                  'Dapatkan pengingat proaktif sebelum kerusakan fatal terjadi.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => ref
                .read(notificationPermissionProvider.notifier)
                .denyPermission(),
            child: const Text('Nanti'),
          ),
          FilledButton(
            onPressed: () => ref
                .read(notificationPermissionProvider.notifier)
                .requestPermission(),
            child: const Text('Izinkan'),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;

    Color iconColor;
    IconData iconData;
    switch (notification.type) {
      case NotificationType.urgent:
        iconColor = Colors.red.shade700;
        iconData = Icons.dangerous_outlined;
        break;
      case NotificationType.warning:
        iconColor = Colors.orange.shade800;
        iconData = Icons.warning_amber_rounded;
        break;
      case NotificationType.booking:
        iconColor = Colors.blue.shade700;
        iconData = Icons.event_available_outlined;
        break;
      case NotificationType.info:
        iconColor = Colors.grey.shade700;
        iconData = Icons.info_outline;
        break;
    }

    return Card(
      elevation: isUnread ? 1 : 0,
      color: isUnread ? Colors.blue.shade50.withValues(alpha: 0.4) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isUnread ? Colors.blue.shade200 : Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight:
                                  isUnread ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          _formatTime(notification.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (notification.route != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• Ketuk untuk lihat',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                color: Colors.grey.shade500,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
