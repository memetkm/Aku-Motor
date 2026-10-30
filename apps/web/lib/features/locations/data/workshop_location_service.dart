import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/location_service.dart';
import '../domain/workshop.dart';

class WorkshopLocationService implements LocationService {
  WorkshopLocationService(this._preferences);

  static const permissionKey = 'aku_motor.location_permission.v1';
  final SharedPreferences? _preferences;

  // Default coordinate: Monas Jakarta Pusat (-6.175392, 106.827153)
  static const defaultCenter = GeoPoint(
    latitude: -6.175392,
    longitude: 106.827153,
    name: 'Pusat Kota (Jakarta)',
  );

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    final prefs = _preferences;
    if (prefs == null) return LocationPermissionStatus.granted;
    final saved = prefs.getString(permissionKey);
    if (saved == LocationPermissionStatus.granted.name) {
      return LocationPermissionStatus.granted;
    }
    if (saved == LocationPermissionStatus.denied.name) {
      return LocationPermissionStatus.denied;
    }
    if (saved == LocationPermissionStatus.serviceDisabled.name) {
      return LocationPermissionStatus.serviceDisabled;
    }
    return LocationPermissionStatus.notDetermined;
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    await _preferences?.setString(
      permissionKey,
      LocationPermissionStatus.granted.name,
    );
    return LocationPermissionStatus.granted;
  }

  @override
  Future<void> denyPermission() async {
    await _preferences?.setString(
      permissionKey,
      LocationPermissionStatus.denied.name,
    );
  }

  @override
  Future<GeoPoint?> getCurrentPosition() async {
    final status = await checkPermission();
    if (status != LocationPermissionStatus.granted) {
      return null;
    }
    // Return realistic user GPS coordinate (e.g., Sudirman / Thamrin)
    return const GeoPoint(
      latitude: -6.180500,
      longitude: 106.828400,
      name: 'Posisi GPS Anda Saat Ini',
    );
  }

  @override
  Future<List<Workshop>> getNearbyWorkshops({
    GeoPoint? position,
    String? categoryFilter,
  }) async {
    final origin = position ?? defaultCenter;
    final all = _buildCatalog(origin);

    var filtered = all;
    if (categoryFilter != null &&
        categoryFilter.isNotEmpty &&
        categoryFilter != 'Semua') {
      filtered = all
          .where((w) =>
              w.brandCategory.toLowerCase() == categoryFilter.toLowerCase())
          .toList();
    }

    // Sort by distance ascending
    filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return filtered;
  }

  List<Workshop> _buildCatalog(GeoPoint origin) {
    final raw = [
      _RawWorkshop(
        id: 'ws-ahass-01',
        name: 'AHASS 001 Astra Motor Jakarta',
        brand: 'Honda',
        address: 'Jl. Dewi Sartika No. 255, Cawang, Jakarta Timur',
        phone: '021-8015555',
        rating: 4.9,
        reviewCount: 342,
        lat: -6.182500,
        lng: 106.831000,
        isOpen: true,
        services: ['Servis Injeksi', 'Ganti Oli & Filter', 'Kelistrikan', 'Suku Cadang Asli'],
      ),
      _RawWorkshop(
        id: 'ws-yamaha-01',
        name: 'Yamaha Flagship Shop Sentral',
        brand: 'Yamaha',
        address: 'Jl. Letjen Suprapto No. 402, Cempaka Putih, Jakarta Pusat',
        phone: '021-4215888',
        rating: 4.8,
        reviewCount: 285,
        lat: -6.186000,
        lng: 106.835000,
        isOpen: true,
        services: ['Servis Berkala', 'Bongkar CVT & V-Belt', 'Uji Emisi', 'Dyno Test'],
      ),
      _RawWorkshop(
        id: 'ws-mitra-01',
        name: 'Bengkel Mitra Modern Motor Jaya',
        brand: 'Umum',
        address: 'Jl. Percetakan Negara No. 12, Rawasari, Jakarta Pusat',
        phone: '0813-8899-7711',
        rating: 4.7,
        reviewCount: 154,
        lat: -6.192000,
        lng: 106.841000,
        isOpen: true,
        services: ['Semua Merek Motor', 'Ganti Ban & Tubeless', 'Servis Rem & Kaliper', 'Ganti Aki'],
      ),
      _RawWorkshop(
        id: 'ws-kawasaki-01',
        name: 'Kawasaki Motor Prima',
        brand: 'Kawasaki',
        address: 'Jl. Jenderal Ahmad Yani No. 88, Jakarta Timur',
        phone: '021-4892222',
        rating: 4.8,
        reviewCount: 98,
        lat: -6.198000,
        lng: 106.849000,
        isOpen: false,
        services: ['Servis Motor Sport', 'Tune Up Ninja', 'Suku Cadang Asli Kawasaki'],
      ),
      _RawWorkshop(
        id: 'ws-suzuki-01',
        name: 'Suzuki Sejahtera Armada Motor',
        brand: 'Suzuki',
        address: 'Jl. Matraman Raya No. 110, Jakarta Timur',
        phone: '021-8581122',
        rating: 4.6,
        reviewCount: 110,
        lat: -6.205000,
        lng: 106.855000,
        isOpen: true,
        services: ['Servis Berkala Suzuki', 'Ganti Oli SGP', 'Sistem Pengereman'],
      ),
      _RawWorkshop(
        id: 'ws-planet-ban-01',
        name: 'Planet Ban Cempaka Putih',
        brand: 'Umum',
        address: 'Jl. Cempaka Putih Barat No. 15, Jakarta Pusat',
        phone: '0812-7766-5544',
        rating: 4.7,
        reviewCount: 220,
        lat: -6.179000,
        lng: 106.839000,
        isOpen: true,
        services: ['Ganti Ban & Pentil', 'Oli X-Ten Mesin', 'Servis Throttle Body'],
      ),
    ];

    return raw.map((r) {
      final dist = _calculateDistance(
        origin.latitude,
        origin.longitude,
        r.lat,
        r.lng,
      );
      return Workshop(
        id: r.id,
        name: r.name,
        brandCategory: r.brand,
        address: r.address,
        phone: r.phone,
        rating: r.rating,
        reviewCount: r.reviewCount,
        distanceKm: double.parse(dist.toStringAsFixed(1)),
        isOpenNow: r.isOpen,
        latitude: r.lat,
        longitude: r.lng,
        services: r.services,
      );
    }).toList();
  }

  // Haversine formula to compute great-circle distance in kilometers
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}

class _RawWorkshop {
  const _RawWorkshop({
    required this.id,
    required this.name,
    required this.brand,
    required this.address,
    required this.phone,
    required this.rating,
    required this.reviewCount,
    required this.lat,
    required this.lng,
    required this.isOpen,
    required this.services,
  });

  final String id;
  final String name;
  final String brand;
  final String address;
  final String phone;
  final double rating;
  final int reviewCount;
  final double lat;
  final double lng;
  final bool isOpen;
  final List<String> services;
}
