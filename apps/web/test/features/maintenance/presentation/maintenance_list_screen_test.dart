import 'dart:async';

import 'package:aku_motor/features/maintenance/application/maintenance_providers.dart';
import 'package:aku_motor/features/maintenance/domain/maintenance_record.dart';
import 'package:aku_motor/features/maintenance/presentation/maintenance_list_screen.dart';
import 'package:aku_motor/features/motors/application/motor_providers.dart';
import 'package:aku_motor/features/motors/domain/motor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_maintenance_repository.dart';
import '../../../support/fake_motor_repository.dart';

void main() {
  final sampleMotor = Motor(
    id: 'motor-1',
    brand: 'Honda',
    model: 'Vario 160',
    year: 2024,
    currentKilometer: 6000,
    createdAt: DateTime(2026),
  );

  final sampleRecord = MaintenanceRecord(
    id: 'rec-1',
    motorId: 'motor-1',
    partType: 'Oli Mesin',
    lastReplacedAt: DateTime(2026, 9, 1),
    lastReplacedKilometer: 4000,
    notes: 'MPX2 0.8L',
    createdAt: DateTime(2026, 9, 1),
  );

  Widget subject({
    required FakeMaintenanceRepository maintenanceRepository,
    FakeMotorRepository? motorRepository,
  }) {
    final motorRepo = motorRepository ?? FakeMotorRepository(motors: [sampleMotor]);
    return ProviderScope(
      overrides: [
        maintenanceRepositoryProvider.overrideWithValue(maintenanceRepository),
        motorRepositoryProvider.overrideWithValue(motorRepo),
      ],
      child: const MaterialApp(home: MaintenanceListScreen()),
    );
  }

  testWidgets('menampilkan loading awal', (tester) async {
    final repo = _DelayedMaintenanceRepository();
    await tester.pumpWidget(subject(maintenanceRepository: repo));
    expect(find.byKey(const Key('initialLoading')), findsOneWidget);
    repo.loadCompleter.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('menampilkan empty state', (tester) async {
    await tester.pumpWidget(
      subject(maintenanceRepository: FakeMaintenanceRepository()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Belum ada catatan servis part'), findsOneWidget);
    expect(find.text('Catat servis pertama'), findsOneWidget);
  });

  testWidgets('menampilkan data servis dan reminder yang berhasil dimuat', (tester) async {
    await tester.pumpWidget(
      subject(
        maintenanceRepository: FakeMaintenanceRepository(records: [sampleRecord]),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('maintenanceList')), findsOneWidget);
    expect(find.text('Oli Mesin'), findsOneWidget);
    expect(find.textContaining('Ganti terakhir:'), findsOneWidget);
    expect(find.textContaining('gak diganti bakal apa?'), findsOneWidget);
  });

  testWidgets('menampilkan error dan dapat mencoba lagi', (tester) async {
    final repo = FakeMaintenanceRepository(loadError: Exception('Database error'));
    await tester.pumpWidget(subject(maintenanceRepository: repo));
    await tester.pumpAndSettle();
    expect(find.text('Data belum berhasil dimuat'), findsOneWidget);

    repo.loadError = null;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada catatan servis part'), findsOneWidget);
    expect(repo.getAllCalls, 2);
  });

  testWidgets('memvalidasi input form pencatatan servis', (tester) async {
    await tester.pumpWidget(
      subject(maintenanceRepository: FakeMaintenanceRepository()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addMaintenanceButton')));
    await tester.pumpAndSettle();

    // Kosongkan field
    await tester.enterText(find.byKey(const Key('lastKilometerField')), '');
    await tester.enterText(find.byKey(const Key('lastDateField')), '');
    await tester.tap(find.byKey(const Key('submitMaintenanceButton')));
    await tester.pump();

    expect(find.text('Wajib diisi'), findsOneWidget);
    expect(find.text('Kilometer harus berupa angka 0 atau lebih'), findsOneWidget);
  });

  testWidgets('mengunci tombol selama submit untuk mencegah double tap', (tester) async {
    final completer = Completer<void>();
    final repo = FakeMaintenanceRepository(createCompleter: completer);
    await tester.pumpWidget(subject(maintenanceRepository: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('addMaintenanceButton')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('lastKilometerField')), '5000');
    await tester.enterText(find.byKey(const Key('lastDateField')), '2026-10-01');
    await tester.tap(find.byKey(const Key('submitMaintenanceButton')));
    await tester.pump();

    expect(find.byKey(const Key('submitMaintenanceLoading')), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('submitMaintenanceButton')),
    );
    expect(button.onPressed, isNull);
    expect(repo.createCalls, 1);

    completer.complete();
    await tester.pumpAndSettle();
    expect(find.text('Oli Mesin'), findsOneWidget);
  });

  testWidgets('menampilkan modal edukasi akibat tanpa fitur gejala', (tester) async {
    await tester.pumpWidget(
      subject(
        maintenanceRepository: FakeMaintenanceRepository(records: [sampleRecord]),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('gak diganti bakal apa?'));
    await tester.pumpAndSettle();

    expect(find.text('Edukasi: Oli Mesin'), findsOneWidget);
    expect(find.text('Kalo gak diganti bakal apa?'), findsOneWidget);
    expect(find.text('1. Akibat Awal / Ringan'), findsOneWidget);
    expect(find.text('3. Akibat Fatal / Berbahaya'), findsOneWidget);
    expect(find.text('Perbandingan Biaya Nyata:'), findsOneWidget);
  });
}

class _DelayedMaintenanceRepository extends FakeMaintenanceRepository {
  final loadCompleter = Completer<List<MaintenanceRecord>>();

  @override
  Future<List<MaintenanceRecord>> getAll() => loadCompleter.future;
}

