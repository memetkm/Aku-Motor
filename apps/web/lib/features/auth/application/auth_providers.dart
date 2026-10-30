import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../motors/application/motor_providers.dart';
import '../data/shared_preferences_auth_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';

class InMemoryAuthRepository implements AuthRepository {
  User? _currentUser;

  @override
  Future<User?> getCurrentUser() async => _currentUser;

  @override
  Future<User> login({required String email, required String password}) async {
    final user = User(
      id: 'mock-user-1',
      name: 'Budi Santoso',
      email: email,
      phoneNumber: '081234567890',
      createdAt: DateTime.now(),
    );
    _currentUser = user;
    return user;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    final user = User(
      id: 'mock-user-reg',
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
    );
    _currentUser = user;
    return user;
  }

  @override
  Future<User> loginAsGuest() async {
    final guest = User.guest();
    _currentUser = guest;
    return guest;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<User> updateProfile({
    required String name,
    required String phoneNumber,
  }) async {
    if (_currentUser == null) {
      throw const FormatException('Tidak ada sesi');
    }
    _currentUser = _currentUser!.copyWith(
      name: name,
      phoneNumber: phoneNumber,
    );
    return _currentUser!;
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) {
    try {
      final prefs = ref.watch(sharedPreferencesProvider);
      return SharedPreferencesAuthRepository(prefs);
    } catch (_) {
      return InMemoryAuthRepository();
    }
  },
);

final authStateProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<User?> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Future<User?> build() => _repository.getCurrentUser();

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getCurrentUser);
  }

  Future<bool> login({required String email, required String password}) async {
    state = const AsyncLoading<User?>().copyWithPrevious(state);
    try {
      final user = await _repository.login(email: email, password: password);
      state = AsyncData(user);
      return true;
    } catch (e, st) {
      state = AsyncError<User?>(e, st).copyWithPrevious(state);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    state = const AsyncLoading<User?>().copyWithPrevious(state);
    try {
      final user = await _repository.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );
      state = AsyncData(user);
      return true;
    } catch (e, st) {
      state = AsyncError<User?>(e, st).copyWithPrevious(state);
      return false;
    }
  }

  Future<bool> loginAsGuest() async {
    state = const AsyncLoading<User?>().copyWithPrevious(state);
    try {
      final guest = await _repository.loginAsGuest();
      state = AsyncData(guest);
      return true;
    } catch (e, st) {
      state = AsyncError<User?>(e, st).copyWithPrevious(state);
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncData(null);
  }

  Future<bool> updateProfile({
    required String name,
    required String phoneNumber,
  }) async {
    state = const AsyncLoading<User?>().copyWithPrevious(state);
    try {
      final user = await _repository.updateProfile(
        name: name,
        phoneNumber: phoneNumber,
      );
      state = AsyncData(user);
      return true;
    } catch (e, st) {
      state = AsyncError<User?>(e, st).copyWithPrevious(state);
      return false;
    }
  }
}

