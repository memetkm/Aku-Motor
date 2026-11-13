import 'user.dart';

/// Repositori khusus untuk data profil pengguna.
/// Bertanggung jawab atas permintaan data/API profil dan memisahkan
/// tanggung jawab profil dari alur autentikasi (login/register).
abstract class ProfileRepository {
  /// Mengambil data profil pengguna yang sedang aktif.
  Future<User?> getProfile();

  /// Memperbarui data profil pengguna ke API/storage.
  Future<User> updateProfile({
    required String name,
    required String phoneNumber,
  });
}
