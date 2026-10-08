import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/error_state.dart';
import '../../motors/application/motor_providers.dart';
import '../../motors/presentation/motor_list_screen.dart';
import '../application/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Aku Motor')),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.read(motorListProvider.notifier).reload(),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Selamat datang', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            const Text('Pantau kendaraan dan rawat sebelum terlambat.'),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SummaryCard(label: 'Total motor', value: '${data.totalMotors}', icon: Icons.two_wheeler),
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
                    Text('Kendaraan terbaru', style: Theme.of(context).textTheme.titleMedium),
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
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, MotorListScreen.routeName),
              icon: const Icon(Icons.garage_outlined),
              label: const Text('Kelola motor'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label),
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
