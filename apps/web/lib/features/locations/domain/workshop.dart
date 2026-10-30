class Workshop {
  const Workshop({
    required this.id,
    required this.name,
    required this.brandCategory,
    required this.address,
    required this.phone,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.isOpenNow,
    required this.latitude,
    required this.longitude,
    required this.services,
  });

  final String id;
  final String name;
  final String brandCategory;
  final String address;
  final String phone;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final bool isOpenNow;
  final double latitude;
  final double longitude;
  final List<String> services;

  Workshop copyWith({
    String? id,
    String? name,
    String? brandCategory,
    String? address,
    String? phone,
    double? rating,
    int? reviewCount,
    double? distanceKm,
    bool? isOpenNow,
    double? latitude,
    double? longitude,
    List<String>? services,
  }) {
    return Workshop(
      id: id ?? this.id,
      name: name ?? this.name,
      brandCategory: brandCategory ?? this.brandCategory,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      distanceKm: distanceKm ?? this.distanceKm,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      services: services ?? this.services,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brandCategory': brandCategory,
        'address': address,
        'phone': phone,
        'rating': rating,
        'reviewCount': reviewCount,
        'distanceKm': distanceKm,
        'isOpenNow': isOpenNow,
        'latitude': latitude,
        'longitude': longitude,
        'services': services,
      };

  factory Workshop.fromJson(Map<String, dynamic> json) => Workshop(
        id: json['id'] as String,
        name: json['name'] as String,
        brandCategory: json['brandCategory'] as String,
        address: json['address'] as String,
        phone: json['phone'] as String,
        rating: (json['rating'] as num).toDouble(),
        reviewCount: json['reviewCount'] as int? ?? 50,
        distanceKm: (json['distanceKm'] as num).toDouble(),
        isOpenNow: json['isOpenNow'] as bool? ?? true,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        services: (json['services'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );
}

