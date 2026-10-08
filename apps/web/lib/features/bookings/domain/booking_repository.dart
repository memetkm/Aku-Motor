import 'booking.dart';

abstract interface class BookingRepository {
  Future<List<Booking>> getAll();
  Future<Booking> create(BookingDraft draft);
  Future<Booking> update(String id, BookingDraft draft);
  Future<void> delete(String id);
}

