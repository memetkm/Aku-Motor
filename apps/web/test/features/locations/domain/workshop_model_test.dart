import 'package:flutter_test/flutter_test.dart';
import 'package:aku_motor/features/locations/domain/location_service.dart';
import 'package:aku_motor/features/locations/domain/workshop.dart';

void main() {
  group('Workshop & GeoPoint Domain Model Tests', () {
    test('Workshop constructor sets all properties correctly', () {
      const workshop = Workshop(
        id: 'ws-1',
        name: 'AHASS Astra',
        brandCategory: 'Honda',
        address: 'Jl. Sudirman No. 1',
        phone: '021-1234567',
        rating: 4.8,
        reviewCount: 120,
        distanceKm: 2.5,
        isOpenNow: true,
        latitude: -6.2000,
        longitude: 106.8166,
        services: ['Servis Ringan', 'Ganti Oli'],
      );

      expect(workshop.id, 'ws-1');
      expect(workshop.name, 'AHASS Astra');
      expect(workshop.brandCategory, 'Honda');
      expect(workshop.rating, 4.8);
      expect(workshop.reviewCount, 120);
      expect(workshop.distanceKm, 2.5);
      expect(workshop.isOpenNow, isTrue);
      expect(workshop.services.length, 2);
    });

    test('Workshop copyWith updates single field while keeping others intact', () {
      const workshop = Workshop(
        id: 'ws-2',
        name: 'Yamaha Flagship',
        brandCategory: 'Yamaha',
        address: 'Jl. Cempaka',
        phone: '021-7654321',
        rating: 4.6,
        reviewCount: 80,
        distanceKm: 3.2,
        isOpenNow: false,
        latitude: -6.1500,
        longitude: 106.8500,
        services: ['Servis Injeksi'],
      );

      final updated = workshop.copyWith(isOpenNow: true, rating: 4.9);
      expect(updated.isOpenNow, isTrue);
      expect(updated.rating, 4.9);
      expect(updated.id, 'ws-2');
      expect(updated.name, 'Yamaha Flagship');
      expect(updated.distanceKm, 3.2);
    });

    test('Workshop copyWith preserves all fields when arguments are null', () {
      const workshop = Workshop(
        id: 'ws-3',
        name: 'Bengkel Umum',
        brandCategory: 'Umum',
        address: 'Jl. Melati',
        phone: '0812345678',
        rating: 4.2,
        reviewCount: 30,
        distanceKm: 1.0,
        isOpenNow: true,
        latitude: -6.1700,
        longitude: 106.8200,
        services: [],
      );

      final clone = workshop.copyWith();
      expect(clone.id, workshop.id);
      expect(clone.name, workshop.name);
      expect(clone.brandCategory, workshop.brandCategory);
    });

    test('Workshop toJson serializes all keys properly', () {
      const workshop = Workshop(
        id: 'ws-json',
        name: 'Planet Ban',
        brandCategory: 'Umum',
        address: 'Jl. Raya',
        phone: '021-9999',
        rating: 4.5,
        reviewCount: 50,
        distanceKm: 1.5,
        isOpenNow: true,
        latitude: -6.18,
        longitude: 106.83,
        services: ['Ganti Ban'],
      );

      final json = workshop.toJson();
      expect(json['id'], 'ws-json');
      expect(json['name'], 'Planet Ban');
      expect(json['rating'], 4.5);
      expect(json['services'], ['Ganti Ban']);
    });

    test('Workshop fromJson parses full JSON map accurately', () {
      final json = {
        'id': 'ws-parsed',
        'name': 'Suzuki Sejahtera',
        'brandCategory': 'Suzuki',
        'address': 'Jl. Pahlawan No. 10',
        'phone': '021-5551234',
        'rating': 4.7,
        'reviewCount': 95,
        'distanceKm': 4.1,
        'isOpenNow': true,
        'latitude': -6.1950,
        'longitude': 106.8400,
        'services': ['Servis Berkala', 'Sparepart Asli'],
      };

      final workshop = Workshop.fromJson(json);
      expect(workshop.id, 'ws-parsed');
      expect(workshop.name, 'Suzuki Sejahtera');
      expect(workshop.brandCategory, 'Suzuki');
      expect(workshop.rating, 4.7);
      expect(workshop.reviewCount, 95);
      expect(workshop.services.length, 2);
    });

    test('Workshop fromJson handles default reviewCount and isOpenNow when omitted', () {
      final json = {
        'id': 'ws-defaults',
        'name': 'Bengkel Sederhana',
        'brandCategory': 'Umum',
        'address': 'Gang Buntu',
        'phone': '08111111',
        'rating': 4.0,
        'distanceKm': 0.8,
        'latitude': -6.18,
        'longitude': 106.82,
      };

      final workshop = Workshop.fromJson(json);
      expect(workshop.reviewCount, 50);
      expect(workshop.isOpenNow, isTrue);
      expect(workshop.services, isEmpty);
    });

    test('GeoPoint toString formats latitude and longitude as string', () {
      const point = GeoPoint(
        latitude: -6.175392,
        longitude: 106.827153,
        name: 'Monas',
      );
      expect(point.toString(), '-6.175392, 106.827153');
      expect(point.name, 'Monas');
    });

    test('GeoPoint default name is empty string', () {
      const point = GeoPoint(latitude: -6.2, longitude: 106.8);
      expect(point.name, '');
    });

    test('LocationPermissionStatus has all defined states', () {
      expect(LocationPermissionStatus.granted.label, 'Diizinkan');
      expect(LocationPermissionStatus.denied.label, 'Ditolak');
      expect(LocationPermissionStatus.serviceDisabled.label, 'GPS Nonaktif');
      expect(LocationPermissionStatus.notDetermined.label, 'Belum Ditentukan');
    });

    test('Workshop sorting by distance ascending orders closest first', () {
      final workshops = [
        const Workshop(
          id: 'ws-far',
          name: 'Jauh',
          brandCategory: 'Honda',
          address: 'A',
          phone: '',
          rating: 4.5,
          reviewCount: 10,
          distanceKm: 8.5,
          isOpenNow: true,
          latitude: 0,
          longitude: 0,
          services: [],
        ),
        const Workshop(
          id: 'ws-near',
          name: 'Dekat',
          brandCategory: 'Honda',
          address: 'B',
          phone: '',
          rating: 4.5,
          reviewCount: 10,
          distanceKm: 1.2,
          isOpenNow: true,
          latitude: 0,
          longitude: 0,
          services: [],
        ),
      ];

      workshops.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      expect(workshops.first.id, 'ws-near');
      expect(workshops.last.id, 'ws-far');
    });

    test('Workshop sorting by rating descending orders highest rated first', () {
      final workshops = [
        const Workshop(
          id: 'ws-low',
          name: 'Bintang 4.0',
          brandCategory: 'Honda',
          address: 'A',
          phone: '',
          rating: 4.0,
          reviewCount: 10,
          distanceKm: 2.0,
          isOpenNow: true,
          latitude: 0,
          longitude: 0,
          services: [],
        ),
        const Workshop(
          id: 'ws-high',
          name: 'Bintang 4.9',
          brandCategory: 'Honda',
          address: 'B',
          phone: '',
          rating: 4.9,
          reviewCount: 10,
          distanceKm: 2.0,
          isOpenNow: true,
          latitude: 0,
          longitude: 0,
          services: [],
        ),
      ];

      workshops.sort((a, b) => b.rating.compareTo(a.rating));
      expect(workshops.first.id, 'ws-high');
      expect(workshops.last.id, 'ws-low');
    });

    test('Workshop filtering by brandCategory matches case insensitively', () {
      final workshops = [
        const Workshop(
          id: '1',
          name: 'AHASS',
          brandCategory: 'Honda',
          address: '',
          phone: '',
          rating: 4.5,
          reviewCount: 10,
          distanceKm: 1.0,
          isOpenNow: true,
          latitude: 0,
          longitude: 0,
          services: [],
        ),
        const Workshop(
          id: '2',
          name: 'Yamaha Shop',
          brandCategory: 'Yamaha',
          address: '',
          phone: '',
          rating: 4.5,
          reviewCount: 10,
          distanceKm: 1.0,
          isOpenNow: true,
          latitude: 0,
          longitude: 0,
          services: [],
        ),
      ];

      final hondaOnly = workshops
          .where((w) => w.brandCategory.toLowerCase() == 'honda')
          .toList();
      expect(hondaOnly.length, 1);
      expect(hondaOnly.first.id, '1');
    });

    test('Workshop filtering by isOpenNow filters open workshops only', () {
      final workshops = [
        const Workshop(
          id: 'open',
          name: 'Buka',
          brandCategory: 'Honda',
          address: '',
          phone: '',
          rating: 4.5,
          reviewCount: 10,
          distanceKm: 1.0,
          isOpenNow: true,
          latitude: 0,
          longitude: 0,
          services: [],
        ),
        const Workshop(
          id: 'closed',
          name: 'Tutup',
          brandCategory: 'Honda',
          address: '',
          phone: '',
          rating: 4.5,
          reviewCount: 10,
          distanceKm: 1.0,
          isOpenNow: false,
          latitude: 0,
          longitude: 0,
          services: [],
        ),
      ];

      final openOnly = workshops.where((w) => w.isOpenNow).toList();
      expect(openOnly.length, 1);
      expect(openOnly.first.id, 'open');
    });

    test('Workshop handles empty services list', () {
      const workshop = Workshop(
        id: 'no-services',
        name: 'Bengkel Mini',
        brandCategory: 'Umum',
        address: 'Jalan Kenanga',
        phone: '081234',
        rating: 4.0,
        reviewCount: 5,
        distanceKm: 0.5,
        isOpenNow: true,
        latitude: 0,
        longitude: 0,
        services: [],
      );
      expect(workshop.services, isEmpty);
    });
  });
}
