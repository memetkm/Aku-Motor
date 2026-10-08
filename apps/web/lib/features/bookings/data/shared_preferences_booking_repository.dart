import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/booking.dart';
import '../domain/booking_repository.dart';

class SharedPreferencesBookingRepository implements BookingRepository {
  SharedPreferencesBookingRepository(this._preferences);

  static const storageKey = 'aku_motor.bookings.v1';
  final SharedPreferences _preferences;
  final _uuid = const Uuid();

  @override
  Future<List<Booking>> getAll() async {
    final raw = _preferences.getString(storageKey);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Booking.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  @override
  Future<Booking> create(BookingDraft draft) async {
    final items = (await getAll()).toList();
    final booking = Booking(
      id: _uuid.v4(),
      motorDescription: draft.motorDescription,
      serviceType: draft.serviceType,
      workshopName: draft.workshopName,
      bookingDate: draft.bookingDate,
      notes: draft.notes,
      status: draft.status,
      createdAt: DateTime.now(),
    );
    items.insert(0, booking);
    await _persist(items);
    return booking;
  }

  @override
  Future<Booking> update(String id, BookingDraft draft) async {
    final items = (await getAll()).toList();
    final index = items.indexWhere((booking) => booking.id == id);
    if (index == -1) {
      throw StateError('Data booking tidak ditemukan.');
    }
    final updated = items[index].copyWith(
      motorDescription: draft.motorDescription,
      serviceType: draft.serviceType,
      workshopName: draft.workshopName,
      bookingDate: draft.bookingDate,
      notes: draft.notes,
      status: draft.status,
    );
    items[index] = updated;
    await _persist(items);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    final items = (await getAll()).where((booking) => booking.id != id).toList();
    await _persist(items);
  }

  Future<void> _persist(List<Booking> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _preferences.setString(storageKey, encoded);
  }
}

