class Booking {
  const Booking({
    required this.id,
    required this.motorDescription,
    required this.serviceType,
    required this.workshopName,
    required this.bookingDate,
    required this.notes,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String motorDescription;
  final String serviceType;
  final String workshopName;
  final DateTime bookingDate;
  final String notes;
  final String status;
  final DateTime createdAt;

  Booking copyWith({
    String? id,
    String? motorDescription,
    String? serviceType,
    String? workshopName,
    DateTime? bookingDate,
    String? notes,
    String? status,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      motorDescription: motorDescription ?? this.motorDescription,
      serviceType: serviceType ?? this.serviceType,
      workshopName: workshopName ?? this.workshopName,
      bookingDate: bookingDate ?? this.bookingDate,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'motorDescription': motorDescription,
        'serviceType': serviceType,
        'workshopName': workshopName,
        'bookingDate': bookingDate.toIso8601String(),
        'notes': notes,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as String,
        motorDescription: json['motorDescription'] as String,
        serviceType: json['serviceType'] as String,
        workshopName: json['workshopName'] as String,
        bookingDate: DateTime.parse(json['bookingDate'] as String),
        notes: json['notes'] as String,
        status: json['status'] as String? ?? 'Menunggu Konfirmasi',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class BookingDraft {
  const BookingDraft({
    required this.motorDescription,
    required this.serviceType,
    required this.workshopName,
    required this.bookingDate,
    required this.notes,
    this.status = 'Menunggu Konfirmasi',
  });

  final String motorDescription;
  final String serviceType;
  final String workshopName;
  final DateTime bookingDate;
  final String notes;
  final String status;
}

