import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../motors/application/motor_providers.dart';
import '../data/shared_preferences_booking_repository.dart';
import '../domain/booking.dart';
import '../domain/booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => SharedPreferencesBookingRepository(ref.watch(sharedPreferencesProvider)),
);

final bookingListProvider =
    AsyncNotifierProvider<BookingListNotifier, List<Booking>>(
  BookingListNotifier.new,
);

class BookingListNotifier extends AsyncNotifier<List<Booking>> {
  BookingRepository get _repository => ref.read(bookingRepositoryProvider);

  @override
  Future<List<Booking>> build() => _repository.getAll();

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getAll);
  }

  Future<bool> create(BookingDraft draft) => _mutate(
        () => _repository.create(draft),
      );

  Future<bool> update(String id, BookingDraft draft) => _mutate(
        () => _repository.update(id, draft),
      );

  Future<bool> delete(String id) => _mutate(
        () => _repository.delete(id),
      );

  Future<bool> _mutate(Future<dynamic> Function() action) async {
    final previous = state.valueOrNull ?? const <Booking>[];
    state = const AsyncLoading<List<Booking>>().copyWithPrevious(state);
    try {
      await action();
      state = AsyncData(await _repository.getAll());
      return true;
    } catch (error, stackTrace) {
      state = AsyncError<List<Booking>>(error, stackTrace)
          .copyWithPrevious(AsyncData(previous));
      return false;
    }
  }
}

