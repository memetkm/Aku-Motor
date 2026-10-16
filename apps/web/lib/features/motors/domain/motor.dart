class Motor {
  const Motor({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.currentKilometer,
    required this.createdAt,
  });

  final String id;
  final String brand;
  final String model;
  final int year;
  final int currentKilometer;
  final DateTime createdAt;

  Motor copyWith({
    String? brand,
    String? model,
    int? year,
    int? currentKilometer,
  }) {
    return Motor(
      id: id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      currentKilometer: currentKilometer ?? this.currentKilometer,
      createdAt: createdAt,
    );
  }

  Map<String, Object> toJson() => {
        'Id': id,
        'Brand': brand,
        'Model': model,
        'Year': year,
        'CurrentKilometer': currentKilometer,
        'CreatedAt': createdAt.toIso8601String(),
      };

  factory Motor.fromJson(Map<String, dynamic> json) {
    final id = json['Id'] ?? json['id'];
    final brand = json['Brand'] ?? json['brand'];
    final model = json['Model'] ?? json['model'];
    final year = json['Year'] ?? json['year'];
    final currentKilometer = json['CurrentKilometer'] ?? json['currentKilometer'];
    final createdAtRaw = json['CreatedAt'] ?? json['createdAt'];

    if (id == null || brand == null || model == null || year == null || currentKilometer == null) {
      throw const FormatException('Data motor tidak valid: atribut wajib tidak lengkap.');
    }

    if (brand is! String || brand.trim().isEmpty) {
      throw const FormatException('Data motor tidak valid: Brand harus berupa string.');
    }
    if (model is! String || model.trim().isEmpty) {
      throw const FormatException('Data motor tidak valid: Model harus berupa string.');
    }

    final parsedYear = year is int ? year : int.tryParse(year.toString());
    if (parsedYear == null) {
      throw const FormatException('Data motor tidak valid: Year harus berupa angka.');
    }

    final parsedKm = currentKilometer is int
        ? currentKilometer
        : int.tryParse(currentKilometer.toString());
    if (parsedKm == null) {
      throw const FormatException('Data motor tidak valid: CurrentKilometer harus berupa angka.');
    }

    DateTime parsedCreatedAt;
    if (createdAtRaw != null) {
      final parsed = DateTime.tryParse(createdAtRaw.toString());
      if (parsed == null) {
        throw const FormatException('Data motor tidak valid: Format tanggal CreatedAt salah.');
      }
      parsedCreatedAt = parsed;
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return Motor(
      id: id.toString(),
      brand: brand,
      model: model,
      year: parsedYear,
      currentKilometer: parsedKm,
      createdAt: parsedCreatedAt,
    );
  }
}

class MotorDraft {
  const MotorDraft({
    required this.brand,
    required this.model,
    required this.year,
    required this.currentKilometer,
  });

  final String brand;
  final String model;
  final int year;
  final int currentKilometer;

  Map<String, dynamic> toJson() => {
        'Brand': brand,
        'Model': model,
        'Year': year,
        'CurrentKilometer': currentKilometer,
      };
}
