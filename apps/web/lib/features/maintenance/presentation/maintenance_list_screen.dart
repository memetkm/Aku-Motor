import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../motors/application/motor_providers.dart';
import '../../motors/domain/motor.dart';
import '../application/maintenance_providers.dart';
import '../domain/maintenance_record.dart';
import 'maintenance_form_dialog.dart';
import 'part_consequence_dialog.dart';

class MaintenanceListScreen extends ConsumerWidget {
  const MaintenanceListScreen({super.key});

  static const routeName = '/maintenance';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenance = ref.watch(maintenanceListProvider);
    final motors = ref.watch(motorListProvider).valueOrNull ?? const <Motor>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Pengingat & Perawatan')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addMaintenanceButton'),
        onPressed: () => _showForm(context),
        icon: const Icon(Icons.add_task),
        label: const Text('Catat servis part'),
      ),
      body: maintenance.when(
        skipLoadingOnRefresh: false,
        loading: () => const Center(
          child: CircularProgressIndicator(key: Key('initialLoading')),
        ),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.read(maintenanceListProvider.notifier).reload(),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              title: 'Belum ada catatan servis part',
              message:
                  'Catat kapan terakhir Anda servis, ganti oli, ban, atau kampas rem '
                  'untuk mengaktifkan pengingat dan edukasi akibatnya jika telat ganti.',
              actionLabel: 'Catat servis pertama',
              icon: Icons.build_circle_outlined,
              onAction: () => _showForm(context),
            );
          }

          return RefreshIndicator(
            onRefresh: ref.read(maintenanceListProvider.notifier).reload,
            child: ListView.separated(
              key: const Key('maintenanceList'),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final record = items[index];
                final matchingMotor = motors.cast<Motor?>().firstWhere(
                      (m) => m?.id == record.motorId,
                      orElse: () => null,
                    );
                final currentKm = matchingMotor?.currentKilometer ??
                    record.lastReplacedKilometer;

                return _MaintenanceCard(
                  record: record,
                  motor: matchingMotor,
                  currentKm: currentKm,
                  onEdit: () => _showForm(context, record: record),
                  onDelete: () => _confirmDelete(context, ref, record),
                  onLearnConsequences: () => _showConsequences(context, record.partType),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showForm(BuildContext context, {MaintenanceRecord? record}) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MaintenanceFormDialog(record: record),
    );
  }

  Future<void> _showConsequences(BuildContext context, String partName) async {
    await showDialog<void>(
      context: context,
      builder: (_) => PartConsequenceDialog(partName: partName),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MaintenanceRecord record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus catatan servis?'),
        content: Text(
          'Catatan penggantian ${record.partType} akan dihapus dari aplikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(maintenanceListProvider.notifier).delete(record.id);
    }
  }
}

class _MaintenanceCard extends StatelessWidget {
  const _MaintenanceCard({
    required this.record,
    required this.motor,
    required this.currentKm,
    required this.onEdit,
    required this.onDelete,
    required this.onLearnConsequences,
  });

  final MaintenanceRecord record;
  final Motor? motor;
  final int currentKm;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLearnConsequences;

  @override
  Widget build(BuildContext context) {
    final status = record.calculateStatus(currentKm);
    final remainingKm = record.calculateRemainingKm(currentKm);
    final remainingDays = record.calculateRemainingDays();
    final theme = Theme.of(context);

    final Color statusColor;
    final IconData statusIcon;
    switch (status) {
      case MaintenanceStatus.urgent:
        statusColor = Colors.red.shade700;
        statusIcon = Icons.error_outline;
      case MaintenanceStatus.warning:
        statusColor = Colors.orange.shade800;
        statusIcon = Icons.warning_amber_rounded;
      case MaintenanceStatus.safe:
        statusColor = Colors.green.shade700;
        statusIcon = Icons.check_circle_outline;
    }

    final dateStr = record.lastReplacedAt.toIso8601String().split('T').first;
    final motorLabel = motor != null ? '${motor!.brand} ${motor!.model}' : 'Motor Utama';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.12),
                  child: Icon(statusIcon, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.partType,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$motorLabel • Ganti terakhir: $dateStr (${record.lastReplacedKilometer} km)',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (val) => val == 'edit' ? onEdit() : onDelete(),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Hapus')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Sisa Jarak Tempuh', style: TextStyle(fontSize: 12)),
                      Text(
                        remainingKm > 0 ? '$remainingKm km' : 'Lewat ${remainingKm.abs()} km!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: remainingKm <= 0 ? Colors.red : null,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Estimasi Waktu', style: TextStyle(fontSize: 12)),
                      Text(
                        remainingDays > 0 ? '$remainingDays hari' : 'Lewat ${remainingDays.abs()} hari!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: remainingDays <= 0 ? Colors.red : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onLearnConsequences,
              icon: const Icon(Icons.privacy_tip_outlined, size: 18),
              label: Text('Kalo ${record.partType} gak diganti bakal apa?'),
              style: OutlinedButton.styleFrom(
                foregroundColor: statusColor,
                side: BorderSide(color: statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

