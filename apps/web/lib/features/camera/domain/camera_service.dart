enum CameraPermissionStatus {
  notDetermined('Belum Ditentukan'),
  granted('Diizinkan'),
  denied('Ditolak');

  const CameraPermissionStatus(this.label);
  final String label;
}

class CameraPhotoResult {
  const CameraPhotoResult({
    required this.photoUrl,
    required this.label,
    required this.capturedAt,
    this.isCancelled = false,
    this.errorMessage,
  });

  final String photoUrl;
  final String label;
  final DateTime capturedAt;
  final bool isCancelled;
  final String? errorMessage;

  bool get isSuccess => !isCancelled && errorMessage == null && photoUrl.isNotEmpty;

  static CameraPhotoResult cancelled() => CameraPhotoResult(
        photoUrl: '',
        label: '',
        capturedAt: DateTime.now(),
        isCancelled: true,
      );

  static CameraPhotoResult error(String message) => CameraPhotoResult(
        photoUrl: '',
        label: '',
        capturedAt: DateTime.now(),
        errorMessage: message,
      );
}

abstract class CameraService {
  Future<CameraPermissionStatus> checkPermission();
  Future<CameraPermissionStatus> requestPermission();
  Future<void> denyPermission();
  Future<CameraPhotoResult> takePhoto({String label = 'Nota Servis'});
  Future<CameraPhotoResult> pickFromGallery({String label = 'Foto Galeri'});
}

