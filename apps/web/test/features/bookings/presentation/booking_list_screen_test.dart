import 'dart:async';

import 'package:aku_motor/features/bookings/application/booking_providers.dart';
import 'package:aku_motor/features/bookings/domain/booking.dart';
import 'package:aku_motor/features/bookings/presentation/booking_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_booking_repository.dart';

void main() {
  final sampleBooking = Booking(
    id: 'b-1',
    motorDescription: 'Honda Vario 160',
    serviceType: 'Servis Berkala / Rutin',
    workshopName: 'AHASS 001 Jakarta',
    bookingDate: DateTime(2026, 10, 15),
    notes: 'Ganti oli mesin dan cek pengereman',
    status: 'Menunggu Konfirmasi',
    createdAt: DateTime(2026, 10, 1),
  );

  Widget subject(FakeBookingRepository repository) {
    return ProviderScope(
      overrides: [bookingRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: BookingListScreen()),
    );
  }

  testWidgets('menampilkan loading awal', (tester) async {
    final repository = _DelayedBookingRepository();
    await tester.pumpWidget(subject(repository));
    expect(find.byKey(const Key('initialLoading')), findsOneWidget);
    repository.loadCompleter.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('menampilkan empty state', (tester) async {
    await tester.pumpWidget(subject(FakeBookingRepository()));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada booking servis'), findsOneWidget);
    expect(find.text('Buat booking sekarang'), findsOneWidget);
  });

  testWidgets('menampilkan data yang berhasil dimuat', (tester) async {
    await tester.pumpWidget(subject(FakeBookingRepository(bookings: [sampleBooking])));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('bookingList')), findsOneWidget);
    expect(find.text('Honda Vario 160'), findsOneWidget);
    expect(find.text('AHASS 001 Jakarta • 2026-10-15'), findsOneWidget);
  });

  testWidgets('menampilkan error dan dapat mencoba lagi', (tester) async {
    final repository = FakeBookingRepository(loadError: Exception('Koneksi storage gagal'));
    await tester.pumpWidget(subject(repository));
    await tester.pumpAndSettle();
    expect(find.text('Data belum berhasil dimuat'), findsOneWidget);

    repository.loadError = null;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada booking servis'), findsOneWidget);
    expect(repository.getAllCalls, 2);
  });

  testWidgets('memvalidasi input pada form booking', (tester) async {
    await tester.pumpWidget(subject(FakeBookingRepository()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addBookingButton')));
    await tester.pumpAndSettle();

    // Kosongkan field tanggal yang secara default terisi hari ini
    await tester.enterText(find.byKey(const Key('dateField')), '');
    await tester.tap(find.byKey(const Key('submitBookingButton')));
    await tester.pump();

    expect(find.text('Wajib diisi'), findsWidgets);
  });

  testWidgets('mengunci tombol selama submit booking untuk mencegah double tap', (tester) async {
    final completer = Completer<void>();
    final repository = FakeBookingRepository(createCompleter: completer);
    await tester.pumpWidget(subject(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('addBookingButton')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('motorField')), 'Yamaha Aerox 155');
    await tester.enterText(find.byKey(const Key('workshopField')), 'Bengkel Yamaha Surya');
    await tester.enterText(find.byKey(const Key('dateField')), '2026-10-20');
    await tester.enterText(
      find.byKey(const Key('notesField')),
      'Ganti oli mesin yamalube dan servis berkala',
    );
    await tester.tap(find.byKey(const Key('submitBookingButton')));
    await tester.pump();

    // Verifikasi indikator loading aktif dan tombol submit disabled
    expect(find.byKey(const Key('submitBookingLoading')), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byKey(const Key('submitBookingButton')));
    expect(button.onPressed, isNull);
    expect(repository.createCalls, 1);

    // Selesaikan proses async submit
    completer.complete();
    await tester.pumpAndSettle();
    expect(find.text('Yamaha Aerox 155'), findsOneWidget);
  });
}

class _DelayedBookingRepository extends FakeBookingRepository {
  final loadCompleter = Completer<List<Booking>>();

  @override
  Future<List<Booking>> getAll() => loadCompleter.future;
}

