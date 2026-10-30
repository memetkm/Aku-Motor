import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../motors/application/motor_providers.dart';
import '../data/workshop_location_service.dart';
import '../domain/location_service.dart';
import '../domain/workshop.dart';

final locationServiceProvider = Provider<LocationService>(
  (ref) {
    try {
      final prefs = ref.watch(sharedPreferencesProvider);
      return WorkshopLocationService(prefs);
    } catch (_) {
      return WorkshopLocationService(null);
    }
  },
);

final locationPermissionProvider =
    StateNotifierProvider<LocationPermissionNotifier, LocationPermissionStatus>(
  (ref) => LocationPermissionNotifier(ref.watch(locationServiceProvider)),
);

class LocationPermissionNotifier extends StateNotifier<LocationPermissionStatus> {
  LocationPermissionNotifier(this._service)
      : super(LocationPermissionStatus.notDetermined) {
    _init();
  }

  final LocationService _service;

  Future<void> _init() async {
    state = await _service.checkPermission();
  }

  Future<void> requestPermission() async {
    state = await _service.requestPermission();
  }

  Future<void> denyPermission() async {
    await _service.denyPermission();
    state = LocationPermissionStatus.denied;
  }
}

final userLocationProvider =
    AsyncNotifierProvider<UserLocationNotifier, GeoPoint?>(
  UserLocationNotifier.new,
);

class UserLocationNotifier extends AsyncNotifier<GeoPoint?> {
  LocationService get _service => ref.read(locationServiceProvider);

  @override
  Future<GeoPoint?> build() => _service.getCurrentPosition();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_service.getCurrentPosition);
  }
}

final workshopCategoryFilterProvider = StateProvider<String>((ref) => 'Semua');

final nearbyWorkshopsProvider = FutureProvider<List<Workshop>>((ref) async {
  final service = ref.watch(locationServiceProvider);
  final position = ref.watch(userLocationProvider).valueOrNull;
  final filter = ref.watch(workshopCategoryFilterProvider);

  return service.getNearbyWorkshops(
    position: position,
    categoryFilter: filter,
  );
});
