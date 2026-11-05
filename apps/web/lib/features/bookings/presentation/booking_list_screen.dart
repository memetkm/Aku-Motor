import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../application/booking_providers.dart';
import '../domain/booking.dart';
import 'booking_form_dialog.dart';

class BookingListScreen extends ConsumerWidget {
  const BookingListScreen({super.key});

  static const routeName = '/bookings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Servis'),
        actions: [
          IconButton(
            tooltip: 'Cari Bengkel Terdekat (GPS)',
            icon: const Icon(Icons.location_on_outlined),
            onPressed: () => Navigator.pushNamed(context, '/workshops'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addBookingButton'),
        onPressed: () => _showForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Buat booking'),
      ),
      body: bookings.when(
        skipLoadingOnRefresh: false,
        loading: () => const Center(
          child: CircularProgressIndicator(key: Key('initialLoading')),
        ),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.read(bookingListProvider.notifier).reload(),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: EmptyState(
                  title: 'Belum ada booking servis',
                  message: 'Jadwalkan perawatan rutin atau perbaikan bengkel dengan mudah.',
                  actionLabel: 'Buat booking sekarang',
                  icon: Icons.calendar_month_outlined,
                  onAction: () => _showForm(context),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(bookingListProvider.notifier).reload();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Daftar booking berhasil diperbarui.'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: ListView.separated(
                  key: const Key('bookingList'),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _BookingCard(
                    booking: items[index],
                    onEdit: () => _showForm(context, booking: items[index]),
                    onDelete: () => _confirmDelete(context, ref, items[index]),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showForm(BuildContext context, {Booking? booking}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BookingFormDialog(booking: booking),
    );
    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            booking == null
                ? 'Booking servis berhasil dikonfirmasi!'
                : 'Perubahan booking berhasil disimpan.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          'Jadwal servis untuk ${booking.motorDescription} '
          'di ${booking.workshopName} akan dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Batalkan booking'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Membatalkan booking...'),
            ],
          ),
          duration: Duration(milliseconds: 600),
          behavior: SnackBarBehavior.floating,
        ),
      );
      final ok = await ref.read(bookingListProvider.notifier).delete(booking.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ok
                  ? 'Booking servis berhasil dibatalkan.'
                  : 'Gagal membatalkan booking.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.onEdit,
    required this.onDelete,
  });

  final Booking booking;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateStr = booking.bookingDate.toIso8601String().split('T').first;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.build_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.motorDescription,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${booking.workshopName} • $dateStr',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Menu opsi booking',
                  onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Batalkan')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(booking.serviceType),
                  avatar: const Icon(Icons.handyman_outlined, size: 16),
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(booking.status),
                  avatar: const Icon(Icons.schedule, size: 16),
                ),
              ],
            ),
            if (booking.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Catatan: ${booking.notes}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
