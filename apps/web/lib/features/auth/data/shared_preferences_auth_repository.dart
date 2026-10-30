import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/auth_repository.dart';
import '../domain/user.dart';

class SharedPreferencesAuthRepository implements AuthRepository {
  SharedPreferencesAuthRepository(this._preferences, {Uuid uuid = const Uuid()})
      : _uuid = uuid;

  static const sessionKey = 'aku_motor.auth_session.v1';
  static const usersDbKey = 'aku_motor.auth_users.v1';

  final SharedPreferences _preferences;
  final Uuid _uuid;

  @override
  Future<User?> getCurrentUser() async {
    final raw = _preferences.getString(sessionKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return User.fromJson(Map<String, dynamic>.from(decoded as Map));
      }
      return User.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<User> login({required String email, required String password}) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || cleanPassword.isEmpty) {
      throw const FormatException('Email dan kata sandi wajib diisi.');
    }

    // Default demo account
    if (cleanEmail == 'budi@akumotor.id' && cleanPassword == 'password123') {
      final user = User(
        id: 'usr-budi-01',
        name: 'Budi Santoso',
        email: cleanEmail,
        phoneNumber: '081234567890',
        createdAt: DateTime(2026, 1, 1),
      );
      await _saveSession(user);
      return user;
    }

    final users = _getRegisteredUsers();
    final matched = users.cast<Map<String, dynamic>?>().firstWhere(
          (u) =>
              (u?['email'] as String?)?.toLowerCase() == cleanEmail &&
              u?['password'] == cleanPassword,
          orElse: () => null,
        );

    if (matched == null) {
      throw const FormatException(
        'Email atau kata sandi tidak cocok. Gunakan akun demo atau daftar akun baru.',
      );
    }

    final user = User.fromJson(matched);
    await _saveSession(user);
    return user;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || password.trim().isEmpty || name.trim().isEmpty) {
      throw const FormatException('Semua field wajib diisi.');
    }
    if (password.length < 6) {
      throw const FormatException('Kata sandi minimal 6 karakter.');
    }

    final users = _getRegisteredUsers();
    final exists = users.any(
      (u) => (u['email'] as String?)?.toLowerCase() == cleanEmail,
    );
    if (exists || cleanEmail == 'budi@akumotor.id') {
      throw const FormatException('Email sudah terdaftar. Silakan login.');
    }

    final newUser = User(
      id: _uuid.v4(),
      name: name.trim(),
      email: cleanEmail,
      phoneNumber: phoneNumber.trim(),
      createdAt: DateTime.now(),
    );

    final record = newUser.toJson();
    record['password'] = password.trim();
    users.add(record);

    await _preferences.setString(usersDbKey, jsonEncode(users));
    await _saveSession(newUser);
    return newUser;
  }

  @override
  Future<User> loginAsGuest() async {
    final guest = User.guest();
    await _saveSession(guest);
    return guest;
  }

  @override
  Future<void> logout() async {
    await _preferences.remove(sessionKey);
  }

  @override
  Future<User> updateProfile({
    required String name,
    required String phoneNumber,
  }) async {
    final current = await getCurrentUser();
    if (current == null) {
      throw const FormatException('Tidak ada sesi pengguna aktif.');
    }

    final updated = current.copyWith(
      name: name.trim(),
      phoneNumber: phoneNumber.trim(),
    );
    await _saveSession(updated);

    // If registered, update in users database as well
    if (!current.isGuest) {
      final users = _getRegisteredUsers();
      final index = users.indexWhere((u) => u['id'] == current.id);
      if (index != -1) {
        users[index]['name'] = updated.name;
        users[index]['phoneNumber'] = updated.phoneNumber;
        await _preferences.setString(usersDbKey, jsonEncode(users));
      }
    }

    return updated;
  }

  List<Map<String, dynamic>> _getRegisteredUsers() {
    final raw = _preferences.getString(usersDbKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _saveSession(User user) async {
    await _preferences.setString(sessionKey, jsonEncode(user.toJson()));
  }
}

