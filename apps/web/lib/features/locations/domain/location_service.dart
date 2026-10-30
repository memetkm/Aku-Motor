import 'workshop.dart';

enum LocationPermissionStatus {
  notDetermined('Belum Ditentukan'),
  granted('Diizinkan'),
  denied('Ditolak'),
  serviceDisabled('GPS Nonaktif');

  const LocationPermissionStatus(this.label);
  final String label;
}

class GeoPoint {
  const GeoPoint({required this.latitude, required this.longitude, this.name = ''});

  final double latitude;
  final double longitude;
  final String name;

  @override
  String toString() => '$latitude, $longitude';
}

abstract class LocationService {
  Future<LocationPermissionStatus> checkPermission();
  Future<LocationPermissionStatus> requestPermission();
  Future<void> denyPermission();
  Future<GeoPoint?> getCurrentPosition();
  Future<List<Workshop>> getNearbyWorkshops({
    GeoPoint? position,
    String? categoryFilter,
  });
}

