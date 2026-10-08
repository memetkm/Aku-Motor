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
    return Motor(
      id: json['Id'] as String,
      brand: json['Brand'] as String,
      model: json['Model'] as String,
      year: json['Year'] as int,
      currentKilometer: json['CurrentKilometer'] as int,
      createdAt: DateTime.parse(json['CreatedAt'] as String),
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
}
