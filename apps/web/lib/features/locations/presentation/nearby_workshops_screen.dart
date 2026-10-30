import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../bookings/presentation/booking_form_dialog.dart';
import '../application/location_providers.dart';
import '../domain/location_service.dart';
import '../domain/workshop.dart';

class NearbyWorkshopsScreen extends ConsumerWidget {
  const NearbyWorkshopsScreen({super.key});

  static const routeName = '/workshops';

  static const categories = [
    'Semua',
    'Honda',
    'Yamaha',
    'Suzuki',
    'Kawasaki',
    'Umum',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permission = ref.watch(locationPermissionProvider);
    final userPosition = ref.watch(userLocationProvider).valueOrNull;
    final selectedCategory = ref.watch(workshopCategoryFilterProvider);
    final workshopsAsync = ref.watch(nearbyWorkshopsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bengkel Terdekat (GPS)'),
        actions: [
          IconButton(
            tooltip: 'Perbarui Lokasi GPS',
            icon: const Icon(Icons.my_location),
            onPressed: () async {
              await ref.read(userLocationProvider.notifier).refresh();
              ref.invalidate(nearbyWorkshopsProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lokasi GPS diperbarui.')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Permission / GPS Status Banner
          _buildLocationBanner(context, ref, permission, userPosition),

          // 2. Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: categories.map((cat) {
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(workshopCategoryFilterProvider.notifier).state =
                          cat;
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // 3. Workshop List
          Expanded(
            child: workshopsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(key: Key('workshopLoading')),
              ),
              error: (err, _) => ErrorState(
                message: err.toString(),
                onRetry: () => ref.refresh(nearbyWorkshopsProvider),
              ),
              data: (workshops) {
                if (workshops.isEmpty) {
                  return EmptyState(
                    title: 'Tidak ada bengkel ditemukan',
                    message:
                        'Tidak ada bengkel kategori "$selectedCategory" di sekitar lokasi Anda. Coba pilih kategori lain.',
                    icon: Icons.location_off_outlined,
                    actionLabel: 'Tampilkan Semua Bengkel',
                    onAction: () {
                      ref.read(workshopCategoryFilterProvider.notifier).state =
                          'Semua';
                    },
                  );
                }

                return ListView.separated(
                  key: const Key('workshopList'),
                  padding: const EdgeInsets.all(16),
                  itemCount: workshops.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = workshops[index];
                    return _WorkshopCard(
                      workshop: item,
                      onCall: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Menghubungi ${item.name} (${item.phone})...',
                            ),
                          ),
                        );
                      },
                      onBooking: () async {
                        await showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => BookingFormDialog(
                            initialWorkshopName: item.name,
                          ),
                        );
                      },
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

  Widget _buildLocationBanner(
    BuildContext context,
    WidgetRef ref,
    LocationPermissionStatus permission,
    GeoPoint? userPosition,
  ) {
    if (permission == LocationPermissionStatus.granted) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Colors.blue.shade800, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GPS Aktif: ${userPosition?.name ?? "Posisi Terdeteksi"}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const Text(
                    'Jarak dihitung secara akurat dari titik Anda saat ini.',
                    style: TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              tooltip: 'Perbarui GPS',
              onPressed: () {
                ref.read(userLocationProvider.notifier).refresh();
                ref.invalidate(nearbyWorkshopsProvider);
              },
            ),
          ],
        ),
      );
    }

    if (permission == LocationPermissionStatus.denied) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.location_off, color: Colors.amber.shade900, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Izin GPS Ditolak',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    'Menampilkan jarak dari titik pusat kota default.',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: () async {
                await ref
                    .read(locationPermissionProvider.notifier)
                    .requestPermission();
                await ref.read(userLocationProvider.notifier).refresh();
                ref.invalidate(nearbyWorkshopsProvider);
              },
              child: const Text('Aktifkan GPS'),
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
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.near_me_outlined, color: Colors.teal.shade800, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Aktifkan Lokasi GPS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  'Temukan bengkel terdekat dan hitung jarak real-time.',
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => ref
                .read(locationPermissionProvider.notifier)
                .denyPermission(),
            child: const Text('Lewati'),
          ),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(locationPermissionProvider.notifier)
                  .requestPermission();
              await ref.read(userLocationProvider.notifier).refresh();
              ref.invalidate(nearbyWorkshopsProvider);
            },
            child: const Text('Izinkan'),
          ),
        ],
      ),
    );
  }
}

class _WorkshopCard extends StatelessWidget {
  const _WorkshopCard({
    required this.workshop,
    required this.onCall,
    required this.onBooking,
  });

  final Workshop workshop;
  final VoidCallback onCall;
  final VoidCallback onBooking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    workshop.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    '${workshop.distanceKm} km',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    workshop.brandCategory,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.star, color: Colors.amber.shade700, size: 16),
                const SizedBox(width: 2),
                Text(
                  '${workshop.rating} (${workshop.reviewCount})',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: workshop.isOpenNow
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    workshop.isOpenNow ? 'Buka Sekarang' : 'Tutup',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: workshop.isOpenNow
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    workshop.address,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: workshop.services.map((srv) {
                return Chip(
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  label: Text(srv, style: const TextStyle(fontSize: 10)),
                  backgroundColor: Colors.grey.shade50,
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: const Text('Hubungi'),
                ),
                const Spacer(),
                FilledButton.icon(
                  key: Key('bookAt_${workshop.id}'),
                  onPressed: onBooking,
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: const Text('Booking di Sini'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

