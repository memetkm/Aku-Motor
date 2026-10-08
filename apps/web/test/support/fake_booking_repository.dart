import 'dart:async';

import 'package:aku_motor/features/bookings/domain/booking.dart';
import 'package:aku_motor/features/bookings/domain/booking_repository.dart';

class FakeBookingRepository implements BookingRepository {
  FakeBookingRepository({
    List<Booking>? bookings,
    this.loadError,
    this.createCompleter,
  }) : _bookings = [...?bookings];

  final List<Booking> _bookings;
  Object? loadError;
  Completer<void>? createCompleter;
  int getAllCalls = 0;
  int createCalls = 0;

  @override
  Future<List<Booking>> getAll() async {
    getAllCalls++;
    if (loadError case final error?) throw error;
    return List.unmodifiable(_bookings);
  }

  @override
  Future<Booking> create(BookingDraft draft) async {
    createCalls++;
    await createCompleter?.future;
    final booking = Booking(
      id: 'booking-$createCalls',
      motorDescription: draft.motorDescription,
      serviceType: draft.serviceType,
      workshopName: draft.workshopName,
      bookingDate: draft.bookingDate,
      notes: draft.notes,
      status: draft.status,
      createdAt: DateTime(2026, 1, createCalls),
    );
    _bookings.add(booking);
    return booking;
  }

  @override
  Future<void> delete(String id) async {
    _bookings.removeWhere((booking) => booking.id == id);
  }

  @override
  Future<Booking> update(String id, BookingDraft draft) async {
    final index = _bookings.indexWhere((booking) => booking.id == id);
    if (index == -1) throw StateError('Booking tidak ditemukan.');
    final booking = _bookings[index].copyWith(
      motorDescription: draft.motorDescription,
      serviceType: draft.serviceType,
      workshopName: draft.workshopName,
      bookingDate: draft.bookingDate,
      notes: draft.notes,
      status: draft.status,
    );
    _bookings[index] = booking;
    return booking;
  }
}

