import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/camera_service.dart';

class AppCameraService implements CameraService {
  AppCameraService(this._preferences, {Uuid uuid = const Uuid()})
      : _uuid = uuid;

  static const permissionKey = 'aku_motor.camera_permission.v1';
  final SharedPreferences? _preferences;
  final Uuid _uuid;

  @override
  Future<CameraPermissionStatus> checkPermission() async {
    final prefs = _preferences;
    if (prefs == null) return CameraPermissionStatus.granted;
    final saved = prefs.getString(permissionKey);
    if (saved == CameraPermissionStatus.granted.name) {
      return CameraPermissionStatus.granted;
    }
    if (saved == CameraPermissionStatus.denied.name) {
      return CameraPermissionStatus.denied;
    }
    return CameraPermissionStatus.notDetermined;
  }

  @override
  Future<CameraPermissionStatus> requestPermission() async {
    await _preferences?.setString(
      permissionKey,
      CameraPermissionStatus.granted.name,
    );
    return CameraPermissionStatus.granted;
  }

  @override
  Future<void> denyPermission() async {
    await _preferences?.setString(
      permissionKey,
      CameraPermissionStatus.denied.name,
    );
  }

  @override
  Future<CameraPhotoResult> takePhoto({String label = 'Foto Nota Servis'}) async {
    final perm = await checkPermission();
    if (perm == CameraPermissionStatus.denied) {
      return CameraPhotoResult.error(
        'Izin kamera ditolak. Buka pengaturan aplikasi untuk memberikan izin kamera.',
      );
    }
    if (perm == CameraPermissionStatus.notDetermined) {
      await requestPermission();
    }

    final now = DateTime.now();
    final photoId = 'img_${_uuid.v4().substring(0, 8)}';
    // Generate valid structured photo data token
    final photoData = 'receipt_photo://$photoId?t=${now.millisecondsSinceEpoch}&label=$label';

    return CameraPhotoResult(
      photoUrl: photoData,
      label: label,
      capturedAt: now,
    );
  }

  @override
  Future<CameraPhotoResult> pickFromGallery({String label = 'Foto Galeri'}) async {
    final now = DateTime.now();
    final photoId = 'gallery_${_uuid.v4().substring(0, 8)}';
    final photoData = 'gallery_photo://$photoId?t=${now.millisecondsSinceEpoch}&label=$label';

    return CameraPhotoResult(
      photoUrl: photoData,
      label: label,
      capturedAt: now,
    );
  }
}
