import 'package:aku_motor/features/locations/data/workshop_location_service.dart';
import 'package:aku_motor/features/locations/domain/location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Location - WorkshopLocationService', () {
    test('Izin GPS: status awal, request, dan deny berjalan benar', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = WorkshopLocationService(prefs);

      expect(await service.checkPermission(), LocationPermissionStatus.notDetermined);

      final granted = await service.requestPermission();
      expect(granted, LocationPermissionStatus.granted);
      expect(await service.checkPermission(), LocationPermissionStatus.granted);

      await service.denyPermission();
      expect(await service.checkPermission(), LocationPermissionStatus.denied);
    });

    test('Mengambil posisi koordinat saat izin diberikan', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = WorkshopLocationService(prefs);

      // Tanpa izin: posisi null
      await service.denyPermission();
      expect(await service.getCurrentPosition(), isNull);

      // Dengan izin: posisi koordinat terisi
      await service.requestPermission();
      final pos = await service.getCurrentPosition();
      expect(pos, isNotNull);
      expect(pos!.latitude, isNotNull);
      expect(pos.longitude, isNotNull);
    });

    test('Mendapatkan daftar bengkel terdekat diurutkan dari jarak terdekat', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = WorkshopLocationService(prefs);

      final workshops = await service.getNearbyWorkshops();
      expect(workshops.isNotEmpty, isTrue);

      // Verifikasi urutan jarak ascending
      for (var i = 0; i < workshops.length - 1; i++) {
        expect(
          workshops[i].distanceKm <= workshops[i + 1].distanceKm,
          isTrue,
        );
      }
    });

    test('Filter bengkel berdasarkan kategori merek (Honda vs Yamaha vs Umum)', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = WorkshopLocationService(prefs);

      final hondaList = await service.getNearbyWorkshops(categoryFilter: 'Honda');
      expect(hondaList.every((w) => w.brandCategory == 'Honda'), isTrue);

      final yamahaList = await service.getNearbyWorkshops(categoryFilter: 'Yamaha');
      expect(yamahaList.every((w) => w.brandCategory == 'Yamaha'), isTrue);

      final allList = await service.getNearbyWorkshops(categoryFilter: 'Semua');
      expect(allList.length >= hondaList.length, isTrue);
    });
  });
}

