import 'package:aku_motor/features/camera/data/app_camera_service.dart';
import 'package:aku_motor/features/camera/domain/camera_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Camera - AppCameraService', () {
    test('Izin kamera: request dan deny berfungsi dengan baik', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = AppCameraService(prefs);

      expect(await service.checkPermission(), CameraPermissionStatus.notDetermined);

      final status = await service.requestPermission();
      expect(status, CameraPermissionStatus.granted);
      expect(await service.checkPermission(), CameraPermissionStatus.granted);

      await service.denyPermission();
      expect(await service.checkPermission(), CameraPermissionStatus.denied);
    });

    test('Ambil foto kamera berhasil menghasilkan token foto dan timestamp', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = AppCameraService(prefs);

      final result = await service.takePhoto(label: 'Nota Ganti Ban');

      expect(result.isSuccess, isTrue);
      expect(result.isCancelled, isFalse);
      expect(result.errorMessage, isNull);
      expect(result.photoUrl.contains('receipt_photo://'), isTrue);
      expect(result.label, 'Nota Ganti Ban');
    });

    test('Pilih dari galeri foto berhasil', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = AppCameraService(prefs);

      final result = await service.pickFromGallery(label: 'Foto Odometer');

      expect(result.isSuccess, isTrue);
      expect(result.photoUrl.contains('gallery_photo://'), isTrue);
      expect(result.label, 'Foto Odometer');
    });

    test('Ambil foto saat izin kamera ditolak mengembalikan pesan error', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = AppCameraService(prefs);

      await service.denyPermission();

      final result = await service.takePhoto(label: 'Nota Ganti Rem');

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, isNotNull);
      expect(result.errorMessage!.contains('Izin kamera ditolak'), isTrue);
    });
  });
}

