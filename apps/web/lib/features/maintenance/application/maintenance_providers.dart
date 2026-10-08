import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../motors/application/motor_providers.dart';
import '../data/shared_preferences_maintenance_repository.dart';
import '../domain/maintenance_record.dart';
import '../domain/maintenance_repository.dart';

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>(
  (ref) => SharedPreferencesMaintenanceRepository(
    ref.watch(sharedPreferencesProvider),
  ),
);

final maintenanceListProvider =
    AsyncNotifierProvider<MaintenanceListNotifier, List<MaintenanceRecord>>(
  MaintenanceListNotifier.new,
);

class MaintenanceListNotifier extends AsyncNotifier<List<MaintenanceRecord>> {
  MaintenanceRepository get _repository => ref.read(maintenanceRepositoryProvider);

  @override
  Future<List<MaintenanceRecord>> build() => _repository.getAll();

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getAll);
  }

  Future<bool> create(MaintenanceDraft draft) => _mutate(
        () => _repository.create(draft),
      );

  Future<bool> update(String id, MaintenanceDraft draft) => _mutate(
        () => _repository.update(id, draft),
      );

  Future<bool> delete(String id) => _mutate(
        () => _repository.delete(id),
      );

  Future<bool> _mutate(Future<dynamic> Function() action) async {
    final previous = state.valueOrNull ?? const <MaintenanceRecord>[];
    state = const AsyncLoading<List<MaintenanceRecord>>().copyWithPrevious(state);
    try {
      await action();
      state = AsyncData(await _repository.getAll());
      return true;
    } catch (error, stackTrace) {
      state = AsyncError<List<MaintenanceRecord>>(error, stackTrace)
          .copyWithPrevious(AsyncData(previous));
      return false;
    }
  }
}

