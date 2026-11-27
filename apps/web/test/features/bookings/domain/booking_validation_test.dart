import 'package:flutter_test/flutter_test.dart';
import 'package:aku_motor/features/bookings/domain/booking.dart';
import 'package:aku_motor/features/bookings/domain/booking_validation.dart';

void main() {
  group('BookingValidation & Booking Domain Tests', () {
    test('valid BookingDraft passes validation with zero errors', () {
      final draft = BookingDraft(
        motorDescription: 'Honda Vario 160 (B 1234 CD)',
        serviceType: 'Servis Ringan & Ganti Oli',
        workshopName: 'AHASS 001 Astra Motor',
        bookingDate: DateTime.now().add(const Duration(days: 2)),
        notes: 'Ganti oli rutin',
      );
      final errors = BookingValidation.validate(draft);
      expect(errors, isEmpty);
      expect(BookingValidation.isValid(draft), isTrue);
    });

    test('empty motorDescription returns validation error', () {
      final draft = BookingDraft(
        motorDescription: '',
        serviceType: 'Servis Ringan',
        workshopName: 'AHASS',
        bookingDate: DateTime.now().add(const Duration(days: 1)),
        notes: '',
      );
      final errors = BookingValidation.validate(draft);
      expect(errors['motorDescription'], contains('tidak boleh kosong'));
      expect(BookingValidation.isValid(draft), isFalse);
    });

    test('motorDescription shorter than 3 characters returns error', () {
      final draft = BookingDraft(
        motorDescription: 'AB',
        serviceType: 'Servis Ringan',
        workshopName: 'AHASS',
        bookingDate: DateTime.now().add(const Duration(days: 1)),
        notes: '',
      );
      final errors = BookingValidation.validate(draft);
      expect(errors['motorDescription'], contains('minimal 3 karakter'));
    });

    test('whitespace-only motorDescription returns error', () {
      final draft = BookingDraft(
        motorDescription: '    ',
        serviceType: 'Servis Ringan',
        workshopName: 'AHASS',
        bookingDate: DateTime.now().add(const Duration(days: 1)),
        notes: '',
      );
      final errors = BookingValidation.validate(draft);
      expect(errors['motorDescription'], contains('tidak boleh kosong'));
    });

    test('empty serviceType returns validation error', () {
      final draft = BookingDraft(
        motorDescription: 'Yamaha NMAX',
        serviceType: '',
        workshopName: 'Yamaha Flagship',
        bookingDate: DateTime.now().add(const Duration(days: 1)),
        notes: '',
      );
      final errors = BookingValidation.validate(draft);
      expect(errors['serviceType'], contains('Pilih jenis layanan'));
    });

    test('empty workshopName returns validation error', () {
      final draft = BookingDraft(
        motorDescription: 'Yamaha NMAX',
        serviceType: 'Servis CVT',
        workshopName: '',
        bookingDate: DateTime.now().add(const Duration(days: 1)),
        notes: '',
      );
      final errors = BookingValidation.validate(draft);
      expect(errors['workshopName'], contains('Nama bengkel tujuan wajib diisi'));
    });

    test('whitespace-only workshopName returns validation error', () {
      final draft = BookingDraft(
        motorDescription: 'Yamaha NMAX',
        serviceType: 'Servis CVT',
        workshopName: '   ',
        bookingDate: DateTime.now().add(const Duration(days: 1)),
        notes: '',
      );
      final errors = BookingValidation.validate(draft);
      expect(errors['workshopName'], contains('Nama bengkel tujuan wajib diisi'));
    });

    test('past booking date returns validation error', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final pastDate = DateTime(2026, 6, 14, 10, 0);
      final draft = BookingDraft(
        motorDescription: 'Yamaha Aerox',
        serviceType: 'Ganti Ban',
        workshopName: 'Planet Ban',
        bookingDate: pastDate,
        notes: '',
      );
      final errors = BookingValidation.validate(draft, now: now);
      expect(errors['bookingDate'], contains('tidak boleh di masa lampau'));
      expect(BookingValidation.isValid(draft, now: now), isFalse);
    });

    test('booking date on today is valid', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final todayDate = DateTime(2026, 6, 15, 16, 0);
      final draft = BookingDraft(
        motorDescription: 'Yamaha Aerox',
        serviceType: 'Ganti Ban',
        workshopName: 'Planet Ban',
        bookingDate: todayDate,
        notes: '',
      );
      final errors = BookingValidation.validate(draft, now: now);
      expect(errors.containsKey('bookingDate'), isFalse);
    });

    test('booking date in future is valid', () {
      final now = DateTime(2026, 6, 15);
      final futureDate = DateTime(2026, 6, 20);
      final draft = BookingDraft(
        motorDescription: 'Yamaha Aerox',
        serviceType: 'Ganti Ban',
        workshopName: 'Planet Ban',
        bookingDate: futureDate,
        notes: '',
      );
      final errors = BookingValidation.validate(draft, now: now);
      expect(errors, isEmpty);
    });

    test('validate accumulates all errors when draft has multiple invalid fields', () {
      final draft = BookingDraft(
        motorDescription: '',
        serviceType: '',
        workshopName: '',
        bookingDate: DateTime(2020, 1, 1),
        notes: '',
      );
      final errors = BookingValidation.validate(draft, now: DateTime(2026, 1, 1));
      expect(errors.length, 4);
      expect(errors.containsKey('motorDescription'), isTrue);
      expect(errors.containsKey('serviceType'), isTrue);
      expect(errors.containsKey('workshopName'), isTrue);
      expect(errors.containsKey('bookingDate'), isTrue);
    });

    test('BookingDraft default status is Menunggu Konfirmasi', () {
      final draft = BookingDraft(
        motorDescription: 'Honda Beat',
        serviceType: 'Tune up',
        workshopName: 'AHASS',
        bookingDate: DateTime.now(),
        notes: '',
      );
      expect(draft.status, 'Menunggu Konfirmasi');
    });

    test('Booking copyWith updates status and notes', () {
      final date = DateTime(2026, 5, 1);
      final booking = Booking(
        id: 'book-1',
        motorDescription: 'Honda Beat',
        serviceType: 'Tune up',
        workshopName: 'AHASS',
        bookingDate: date,
        notes: 'Pagi',
        status: 'Menunggu Konfirmasi',
        createdAt: date,
      );
      final updated = booking.copyWith(
        status: 'Dikonfirmasi',
        notes: 'Siang jam 13:00',
      );
      expect(updated.status, 'Dikonfirmasi');
      expect(updated.notes, 'Siang jam 13:00');
      expect(updated.id, 'book-1');
      expect(updated.motorDescription, 'Honda Beat');
    });

    test('Booking copyWith preserves all fields when null', () {
      final date = DateTime(2026, 5, 1);
      final booking = Booking(
        id: 'book-2',
        motorDescription: 'Honda Beat',
        serviceType: 'Tune up',
        workshopName: 'AHASS',
        bookingDate: date,
        notes: 'Catatan',
        status: 'Selesai',
        createdAt: date,
      );
      final clone = booking.copyWith();
      expect(clone.id, booking.id);
      expect(clone.status, booking.status);
    });

    test('Booking toJson produces map with expected ISO date strings', () {
      final date = DateTime(2026, 5, 1, 10, 0);
      final booking = Booking(
        id: 'book-json',
        motorDescription: 'Suzuki Nex II',
        serviceType: 'Oli mesin',
        workshopName: 'Suzuki Authorized',
        bookingDate: date,
        notes: 'Oli SGP',
        status: 'Selesai',
        createdAt: date,
      );
      final json = booking.toJson();
      expect(json['id'], 'book-json');
      expect(json['motorDescription'], 'Suzuki Nex II');
      expect(json['bookingDate'], date.toIso8601String());
      expect(json['status'], 'Selesai');
    });

    test('Booking fromJson parses JSON map correctly with default status', () {
      final json = {
        'id': 'book-3',
        'motorDescription': 'Kawasaki W175',
        'serviceType': 'Servis Karbu',
        'workshopName': 'Kawasaki Motor',
        'bookingDate': '2026-07-20T09:00:00.000',
        'notes': 'Cek langsam',
        'createdAt': '2026-07-15T09:00:00.000',
      };
      final booking = Booking.fromJson(json);
      expect(booking.id, 'book-3');
      expect(booking.motorDescription, 'Kawasaki W175');
      expect(booking.status, 'Menunggu Konfirmasi');
      expect(booking.bookingDate.year, 2026);
    });
  });
}
