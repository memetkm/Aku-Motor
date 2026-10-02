import 'dart:async';

import 'package:aku_motor/features/motors/application/motor_providers.dart';
import 'package:aku_motor/features/motors/domain/motor.dart';
import 'package:aku_motor/features/motors/presentation/motor_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_motor_repository.dart';

void main() {
  final sampleMotor = Motor(
    id: '1',
    brand: 'Honda',
    model: 'Vario 160',
    year: 2024,
    currentKilometer: 8500,
    createdAt: DateTime(2026),
  );

  Widget subject(FakeMotorRepository repository) {
    return ProviderScope(
      overrides: [motorRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: MotorListScreen()),
    );
  }

  testWidgets('menampilkan loading awal', (tester) async {
    final repository = _DelayedLoadRepository();
    await tester.pumpWidget(subject(repository));
    expect(find.byKey(const Key('initialLoading')), findsOneWidget);
    repository.loadCompleter.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('menampilkan empty state', (tester) async {
    await tester.pumpWidget(subject(FakeMotorRepository()));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada motor'), findsOneWidget);
    expect(find.text('Tambah sekarang'), findsOneWidget);
  });

  testWidgets('menampilkan data yang berhasil dimuat', (tester) async {
    await tester.pumpWidget(subject(FakeMotorRepository(motors: [sampleMotor])));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('motorList')), findsOneWidget);
    expect(find.text('Honda Vario 160'), findsOneWidget);
    expect(find.text('2024 • 8500 km'), findsOneWidget);
  });

  testWidgets('menampilkan error dan dapat mencoba lagi', (tester) async {
    final repository = FakeMotorRepository(loadError: Exception('Storage gagal'));
    await tester.pumpWidget(subject(repository));
    await tester.pumpAndSettle();
    expect(find.text('Data belum berhasil dimuat'), findsOneWidget);

    repository.loadError = null;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada motor'), findsOneWidget);
    expect(repository.getAllCalls, 2);
  });

  testWidgets('memvalidasi input kosong dan angka', (tester) async {
    await tester.pumpWidget(subject(FakeMotorRepository()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addMotorButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('submitMotorButton')));
    await tester.pump();
    expect(find.text('Wajib diisi'), findsNWidgets(2));
    expect(find.textContaining('Masukkan tahun'), findsOneWidget);
    expect(find.text('Kilometer harus berupa angka 0 atau lebih'), findsOneWidget);
  });

  testWidgets('mengunci tombol selama submit untuk mencegah double tap', (tester) async {
    final completer = Completer<void>();
    final repository = FakeMotorRepository(createCompleter: completer);
    await tester.pumpWidget(subject(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addMotorButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('brandField')), 'Yamaha');
    await tester.enterText(find.byKey(const Key('modelField')), 'NMAX');
    await tester.enterText(find.byKey(const Key('yearField')), '2025');
    await tester.enterText(find.byKey(const Key('kilometerField')), '1200');
    await tester.tap(find.byKey(const Key('submitMotorButton')));
    await tester.pump();

    expect(find.byKey(const Key('submitLoading')), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byKey(const Key('submitMotorButton')));
    expect(button.onPressed, isNull);
    expect(repository.createCalls, 1);

    completer.complete();
    await tester.pumpAndSettle();
    expect(find.text('Yamaha NMAX'), findsOneWidget);
  });
}

class _DelayedLoadRepository extends FakeMotorRepository {
  final loadCompleter = Completer<List<Motor>>();

  @override
  Future<List<Motor>> getAll() => loadCompleter.future;
}
