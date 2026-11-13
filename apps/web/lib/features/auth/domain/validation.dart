/// Aturan validasi input untuk modul autentikasi dan profil pengguna.
/// Memisahkan logika validasi murni dari komponen UI untuk menghindari duplikasi kode.
class ValidationRules {
  const ValidationRules._();

  /// Validasi nama pengguna (wajib diisi, non-empty setelah di-trim).
  static String? validateName(
    String? value, {
    String emptyMessage = 'Nama wajib diisi',
  }) {
    if (value == null || value.trim().isEmpty) {
      return emptyMessage;
    }
    return null;
  }

  /// Validasi email (wajib diisi, mengandung '@' dan '.').
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    final trimmed = value.trim();
    if (!trimmed.contains('@') || !trimmed.contains('.')) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validasi nomor telepon / WhatsApp (wajib diisi, opsional batas panjang minimal).
  static String? validatePhone(
    String? value, {
    int minLength = 0,
    String emptyMessage = 'Nomor HP wajib diisi',
    String shortMessage = 'Nomor HP terlalu pendek',
  }) {
    if (value == null || value.trim().isEmpty) {
      return emptyMessage;
    }
    if (minLength > 0 && value.trim().length < minLength) {
      return shortMessage;
    }
    return null;
  }

  /// Validasi kata sandi (wajib diisi, minimal 6 karakter).
  static String? validatePassword(
    String? value, {
    int minLength = 6,
    String emptyMessage = 'Kata sandi wajib diisi',
  }) {
    if (value == null || value.trim().isEmpty) {
      return emptyMessage;
    }
    if (value.trim().length < minLength) {
      return 'Kata sandi minimal $minLength karakter';
    }
    return null;
  }

  /// Validasi konfirmasi kata sandi (harus cocok dengan kata sandi utama).
  static String? validateConfirmPassword(
    String? confirmValue,
    String originalPassword,
  ) {
    if (confirmValue != originalPassword) {
      return 'Konfirmasi kata sandi tidak cocok';
    }
    return null;
  }

  /// Validasi umum field wajib diisi.
  static String? validateRequired(
    String? value, {
    String message = 'Wajib diisi',
  }) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }
}
