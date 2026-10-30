import 'user.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> login({required String email, required String password});
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  });
  Future<User> loginAsGuest();
  Future<void> logout();
  Future<User> updateProfile({required String name, required String phoneNumber});
}

