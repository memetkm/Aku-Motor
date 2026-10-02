import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/shared_preferences_motor_repository.dart';
import '../domain/motor.dart';
import '../domain/motor_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences belum diinisialisasi.'),
);

final motorRepositoryProvider = Provider<MotorRepository>(
  (ref) => SharedPreferencesMotorRepository(ref.watch(sharedPreferencesProvider)),
);

final motorListProvider =
    AsyncNotifierProvider<MotorListNotifier, List<Motor>>(MotorListNotifier.new);

class MotorListNotifier extends AsyncNotifier<List<Motor>> {
  MotorRepository get _repository => ref.read(motorRepositoryProvider);

  @override
  Future<List<Motor>> build() => _repository.getAll();

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getAll);
  }

  Future<bool> create(MotorDraft draft) => _mutate(
        () => _repository.create(draft),
      );

  Future<bool> update(String id, MotorDraft draft) => _mutate(
        () => _repository.update(id, draft),
      );

  Future<bool> delete(String id) => _mutate(
        () => _repository.delete(id),
      );

  Future<bool> _mutate(Future<void> Function() action) async {
    final previous = state.valueOrNull ?? const <Motor>[];
    state = const AsyncLoading<List<Motor>>().copyWithPrevious(state);
    try {
      await action();
      state = AsyncData(await _repository.getAll());
      return true;
    } catch (error, stackTrace) {
      state = AsyncError<List<Motor>>(error, stackTrace)
          .copyWithPrevious(AsyncData(previous));
      return false;
    }
  }
}
