import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../motors/application/motor_providers.dart';
import '../data/app_camera_service.dart';
import '../domain/camera_service.dart';

final cameraServiceProvider = Provider<CameraService>(
  (ref) {
    try {
      final prefs = ref.watch(sharedPreferencesProvider);
      return AppCameraService(prefs);
    } catch (_) {
      return AppCameraService(null);
    }
  },
);

final cameraPermissionProvider =
    StateNotifierProvider<CameraPermissionNotifier, CameraPermissionStatus>(
  (ref) => CameraPermissionNotifier(ref.watch(cameraServiceProvider)),
);

class CameraPermissionNotifier extends StateNotifier<CameraPermissionStatus> {
  CameraPermissionNotifier(this._service)
      : super(CameraPermissionStatus.notDetermined) {
    _init();
  }

  final CameraService _service;

  Future<void> _init() async {
    state = await _service.checkPermission();
  }

  Future<void> requestPermission() async {
    state = await _service.requestPermission();
  }

  Future<void> denyPermission() async {
    await _service.denyPermission();
    state = CameraPermissionStatus.denied;
  }
}
