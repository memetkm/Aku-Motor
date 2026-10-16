import 'package:aku_motor/core/network/api_client.dart';
import 'package:aku_motor/features/motors/application/motor_providers.dart';
import 'package:aku_motor/features/motors/data/api_motor_repository.dart';
import 'package:aku_motor/features/motors/presentation/motor_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_motor_repository_test.dart';

void main() {
  Widget subject(MockApiClient client) {
    final repository = ApiMotorRepository(client);
    return ProviderScope(
      overrides: [motorRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: MotorListScreen()),
    );
  }

  testWidgets(
    'Vertical Slice: Loading, Error, Retry, Empty, dan Success terhubung dengan Backend API',
    (tester) async {
      // 1. Uji Error State dari Backend HTTP 500
      final client = MockApiClient(
        response: const ApiResponse(
          statusCode: 500,
          body: 'Server Database Sedang Bermasalah',
        ),
      );

      await tester.pumpWidget(subject(client));
      await tester.pumpAndSettle();

      // UI menampilkan ErrorState dan tombol Coba lagi
      expect(find.text('Data belum berhasil dimuat'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);

      // 2. Uji Retry & Success State: Server pulih dan mengembalikan data
      client.response = const ApiResponse(
        statusCode: 200,
        body: '''
        [
          {
            "Id": 10,
            "Brand": "Yamaha",
            "Model": "NMAX 155",
            "Year": 2024,
            "CurrentKilometer": 8500,
            "CreatedAt": "2026-10-01T00:00:00.000Z"
          }
        ]
        ''',
      );

      // Tap tombol Coba lagi (Retry)
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();

      // UI menampilkan data motor yang berhasil dimuat dari API (Success)
      expect(find.text('Yamaha NMAX 155'), findsOneWidget);
      expect(find.text('2024 • 8500 km'), findsOneWidget);

      // 3. Uji Empty State: Server mengembalikan array kosong []
      client.response = const ApiResponse(statusCode: 200, body: '[]');

      // Trigger reload ulang
      final element = tester.element(find.byType(MotorListScreen));
      final container = ProviderScope.containerOf(element);
      container.read(motorListProvider.notifier).reload();
      await tester.pumpAndSettle();

      // UI menampilkan EmptyState
      expect(find.text('Belum ada motor'), findsOneWidget);
      expect(find.text('Tambah sekarang'), findsOneWidget);
    },
  );
}

