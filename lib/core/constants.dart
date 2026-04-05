// lib/core/constants.dart
class AppConstants {
  // ✅ Ganti sesuai device:
  // Emulator Android: 10.0.2.2
  // Physical Device: IP laptop Anda (misal: 192.168.1.100)
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Image
  static const String baseImageUrl = 'http://127.0.0.1:8000/storage/record/';
  // ✅ Token expiration dalam detik (3 jam)
  static const int tokenExpirationSeconds = 3 * 60 * 60;

  // ✅ Keys untuk SharedPreferences
  static const String keyAuthToken = 'auth_token';
  static const String keyUserData = 'user_data';
  static const String keyTokenExpiresAt = 'token_expires_at';
}
