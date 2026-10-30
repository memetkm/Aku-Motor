import 'package:aku_motor/features/locations/application/location_providers.dart';
import 'package:aku_motor/features/locations/data/workshop_location_service.dart';
import 'package:aku_motor/features/locations/presentation/nearby_workshops_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NearbyWorkshopsScreen menampilkan daftar bengkel dan filter', (tester) async {
    final service = WorkshopLocationService(null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          locationServiceProvider.overrideWithValue(service),
        ],
        child: const MaterialApp(
          home: NearbyWorkshopsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bengkel Terdekat (GPS)'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Honda'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Yamaha'), findsOneWidget);

    // Memastikan daftar bengkel termuat
    expect(find.byKey(const Key('workshopList')), findsOneWidget);
  });
}
