import 'package:aku_motor/features/bookings/data/shared_preferences_booking_repository.dart';
import 'package:aku_motor/features/bookings/domain/booking.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('CRUD booking tersimpan dan dapat dibaca repository baru', () async {
    final preferences = await SharedPreferences.getInstance();
    final firstSession = SharedPreferencesBookingRepository(preferences);
    final created = await firstSession.create(
      BookingDraft(
        motorDescription: 'Honda Vario 160',
        workshopName: 'AHASS 001 Jakarta',
        serviceType: 'Servis Berkala / Rutin',
        bookingDate: DateTime(2026, 10, 15),
        notes: 'Ganti oli mesin dan cek rem',
      ),
    );

    final reopenedSession = SharedPreferencesBookingRepository(
      await SharedPreferences.getInstance(),
    );
    expect((await reopenedSession.getAll()).single.id, created.id);
    expect((await reopenedSession.getAll()).single.workshopName, 'AHASS 001 Jakarta');

    await reopenedSession.update(
      created.id,
      BookingDraft(
        motorDescription: 'Honda Vario 160',
        workshopName: 'AHASS 001 Jakarta Pusat',
        serviceType: 'Ganti Oli & Filter',
        bookingDate: DateTime(2026, 10, 16),
        notes: 'Ganti oli mesin dan filter udara',
      ),
    );
    expect((await reopenedSession.getAll()).single.workshopName, 'AHASS 001 Jakarta Pusat');
    expect((await reopenedSession.getAll()).single.serviceType, 'Ganti Oli & Filter');

    await reopenedSession.delete(created.id);
    expect(await reopenedSession.getAll(), isEmpty);
  });
}

