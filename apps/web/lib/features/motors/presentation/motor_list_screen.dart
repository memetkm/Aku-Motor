import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../application/motor_providers.dart';
import '../domain/motor.dart';
import 'motor_form_dialog.dart';

class MotorListScreen extends ConsumerWidget {
  const MotorListScreen({super.key});

  static const routeName = '/motors';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motors = ref.watch(motorListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Motor saya')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addMotorButton'),
        onPressed: () => _showForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah motor'),
      ),
      body: motors.when(
        skipLoadingOnRefresh: false,
        loading: () => const Center(
          child: CircularProgressIndicator(key: Key('initialLoading')),
        ),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.read(motorListProvider.notifier).reload(),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              title: 'Belum ada motor',
              message: 'Tambahkan motor pertama untuk mulai mencatat perawatan.',
              actionLabel: 'Tambah sekarang',
              onAction: () => _showForm(context),
            );
          }
          return RefreshIndicator(
            onRefresh: ref.read(motorListProvider.notifier).reload,
            child: ListView.separated(
              key: const Key('motorList'),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _MotorCard(
                motor: items[index],
                onEdit: () => _showForm(context, motor: items[index]),
                onDelete: () => _confirmDelete(context, ref, items[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showForm(BuildContext context, {Motor? motor}) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MotorFormDialog(motor: motor),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Motor motor,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus motor?'),
        content: Text('${motor.brand} ${motor.model} akan dihapus dari perangkat.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(motorListProvider.notifier).delete(motor.id);
    }
  }
}

class _MotorCard extends StatelessWidget {
  const _MotorCard({
    required this.motor,
    required this.onEdit,
    required this.onDelete,
  });

  final Motor motor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          child: Text(motor.brand.characters.first.toUpperCase()),
        ),
        title: Text('${motor.brand} ${motor.model}'),
        subtitle: Text('${motor.year} • ${motor.currentKilometer} km'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Hapus')),
          ],
        ),
      ),
    );
  }
}
