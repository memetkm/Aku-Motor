class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.photoUrl = '',
    required this.createdAt,
    this.isGuest = false,
  });

  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String photoUrl;
  final DateTime createdAt;
  final bool isGuest;

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    DateTime? createdAt,
    bool? isGuest,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'photoUrl': photoUrl,
        'createdAt': createdAt.toIso8601String(),
        'isGuest': isGuest,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phoneNumber: json['phoneNumber'] as String? ?? '',
        photoUrl: json['photoUrl'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        isGuest: json['isGuest'] as bool? ?? false,
      );

  static User guest() => User(
        id: 'guest-user',
        name: 'Pengendara Tamu',
        email: 'tamu@akumotor.id',
        phoneNumber: '-',
        photoUrl: '',
        createdAt: DateTime.now(),
        isGuest: true,
      );
}

