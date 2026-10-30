enum NotificationType {
  info('Info', 'Informasi umum'),
  warning('Peringatan', 'Jadwal servis sudah dekat'),
  urgent('Penting / Bahaya', 'Batas servis terlampaui'),
  booking('Booking Servis', 'Pembaruan jadwal servis bengkel');

  const NotificationType(this.label, this.description);
  final String label;
  final String description;
}

enum NotificationPermissionStatus {
  notDetermined('Belum Ditentukan'),
  granted('Diizinkan'),
  denied('Ditolak');

  const NotificationPermissionStatus(this.label);
  final String label;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.partName,
    this.route,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? partName;
  final String? route;

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? partName,
    String? route,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      partName: partName ?? this.partName,
      route: route ?? this.route,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
        'partName': partName,
        'route': route,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        type: NotificationType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => NotificationType.info,
        ),
        timestamp: DateTime.parse(json['timestamp'] as String),
        isRead: json['isRead'] as bool? ?? false,
        partName: json['partName'] as String?,
        route: json['route'] as String?,
      );
}

