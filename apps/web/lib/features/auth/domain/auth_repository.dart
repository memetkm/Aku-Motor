import 'profile_repository.dart';
import 'user.dart';

abstract class AuthRepository implements ProfileRepository {
  Future<User?> getCurrentUser();

  @override
  Future<User?> getProfile();

  Future<User> login({required String email, required String password});
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  });
  Future<User> loginAsGuest();
  Future<void> logout();

  @override
  Future<User> updateProfile({required String name, required String phoneNumber});
}

