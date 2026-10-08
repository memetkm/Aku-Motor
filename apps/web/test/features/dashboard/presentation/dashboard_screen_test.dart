import 'package:aku_motor/features/dashboard/presentation/dashboard_screen.dart';
import 'package:aku_motor/features/motors/application/motor_providers.dart';
import 'package:aku_motor/features/motors/domain/motor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_motor_repository.dart';

void main() {
  testWidgets('merangkum state motor secara reaktif', (tester) async {
    final repository = FakeMotorRepository(
      motors: [
        Motor(
          id: '1',
          brand: 'Honda',
          model: 'Vario',
          year: 2024,
          currentKilometer: 12000,
          createdAt: DateTime(2026),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [motorRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('12000 km'), findsOneWidget);
    expect(find.text('Honda Vario'), findsOneWidget);
  });
}
