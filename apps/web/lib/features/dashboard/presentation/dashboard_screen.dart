import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/error_state.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/presentation/profile_dialog.dart';
import '../../bookings/presentation/booking_list_screen.dart';
import '../../locations/presentation/nearby_workshops_screen.dart';
import '../../maintenance/presentation/maintenance_list_screen.dart';
import '../../motors/application/motor_providers.dart';
import '../../motors/presentation/motor_list_screen.dart';
import '../../notifications/application/notification_providers.dart';
import '../../notifications/presentation/notification_list_screen.dart';
import '../../sensor/presentation/emergency_sos_dialog.dart';
import '../application/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aku Motor'),
        actions: [
          // 1. Sensor & Emergency SOS Button
          IconButton(
            key: const Key('emergencySosButton'),
            tooltip: 'Bantuan Darurat SOS (Sensor)',
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sos, color: Colors.red.shade900, size: 22),
            ),
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (_) => const EmergencySosDialog(),
              );
            },
          ),
          // 2. Notification Center with Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                key: const Key('notificationsButton'),
                tooltip: 'Notifikasi & Pengingat',
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.pushNamed(
                  context,
                  NotificationListScreen.routeName,
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // 3. User Authentication / Profile
          IconButton(
            key: const Key('userProfileButton'),
            tooltip: user != null ? 'Profil Akun' : 'Masuk Akun',
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                user != null ? Icons.person : Icons.person_outline,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onPressed: () {
              if (user != null) {
                showDialog<void>(
                  context: context,
                  builder: (_) => ProfileDialog(user: user),
                );
              } else {
                Navigator.pushNamed(context, LoginScreen.routeName);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.read(motorListProvider.notifier).reload(),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              user != null ? 'Selamat datang, ${user.name}' : 'Selamat datang',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            const Text('Pantau kendaraan dan rawat sebelum terlambat.'),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SummaryCard(
                  label: 'Total motor',
                  value: '${data.totalMotors}',
                  icon: Icons.two_wheeler,
                ),
                _SummaryCard(
                  label: 'Total kilometer',
                  value: '${data.totalKilometer} km',
                  icon: Icons.speed,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kendaraan terbaru',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data.latestMotor == null
                          ? 'Belum ada motor yang disimpan.'
                          : '${data.latestMotor!.brand} ${data.latestMotor!.model}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Main Action Buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  key: const Key('manageMotorButton'),
                  onPressed: () =>
                      Navigator.pushNamed(context, MotorListScreen.routeName),
                  icon: const Icon(Icons.garage_outlined),
                  label: const Text('Kelola motor'),
                ),
                FilledButton.tonalIcon(
                  key: const Key('maintenanceButton'),
                  onPressed: () => Navigator.pushNamed(
                    context,
                    MaintenanceListScreen.routeName,
                  ),
                  icon: const Icon(Icons.build_circle_outlined),
                  label: const Text('Pengingat servis'),
                ),
                FilledButton.tonalIcon(
                  key: const Key('manageBookingsButton'),
                  onPressed: () => Navigator.pushNamed(
                    context,
                    BookingListScreen.routeName,
                  ),
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Booking servis'),
                ),
                FilledButton.tonalIcon(
                  key: const Key('workshopsButton'),
                  onPressed: () => Navigator.pushNamed(
                    context,
                    NearbyWorkshopsScreen.routeName,
                  ),
                  icon: const Icon(Icons.near_me_outlined),
                  label: const Text('Bengkel terdekat (GPS)'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Advanced Features Quick Guide Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.blue.shade100),
              ),
              color: Colors.blue.shade50.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Fitur Cerdas Aku Motor',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '• 🔐 Autentikasi: Sesi akun aman & profil pemilik motor.\n'
                      '• 🔔 Notifikasi: Peringatan dini sebelum batas oli & rem habis.\n'
                      '• 📍 Lokasi GPS: Deteksi bengkel resmi terdekat & booking instan.\n'
                      '• 📷 Kamera: Dokumentasi foto nota servis & bukti odometer.\n'
                      '• 🚨 Sensor SOS: Deteksi guncangan & bantuan derek 24 jam.',
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
