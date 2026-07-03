// lib/data/services/auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final _api = ApiClient();

  // ✅ Login & simpan token + user
  Future<UserModel> login(String email, String password) async {
    final response = await _api.post('loginuser', {
      'email': email,
      'password': password,
    }, requireAuth: false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final userData = data['data']['user'];
        final token = data['data']['access_token'];
        final hmacKey = data['data']['hmac_session_key'];
        final expiresIn =
            data['data']['expires_in'] ?? AppConstants.tokenExpirationSeconds;

        // ✅ Simpan token & user
        await _saveToken(token, hmacKey, expiresIn);
        final user = UserModel.fromJson(userData);
        await _saveUser(user);

        return user;
      }
    }

    final errorData = jsonDecode(response.body);
    throw Exception(errorData['message'] ?? 'Login gagal');
  }

  // ✅ Logout & clear token
  Future<void> logout() async {
    try {
      await _api.post('logout', {}, requireAuth: true);
    } catch (_) {
      // Ignore error, tetap clear local storage
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAuthToken);
    await prefs.remove(AppConstants.keyUserData);
    await prefs.remove(AppConstants.keyTokenExpiresAt);
  }

  // ✅ Simpan token + expiration time
  Future<void> _saveToken(
    String token,
    String hmacKey,
    int expiresInSeconds,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(AppConstants.keyAuthToken, token);
    await prefs.setString('hmac_session_key', hmacKey);

    print("SAVE TOKEN : ${prefs.getString(AppConstants.keyAuthToken)}");
    print("SAVE HMAC  : ${prefs.getString('hmac_session_key')}");

    await prefs.setString(AppConstants.keyHmacSession, hmacKey);

    print("SAVE HMAC : ${prefs.getString(AppConstants.keyHmacSession)}");

    final expiresAt = DateTime.now().add(Duration(seconds: expiresInSeconds));

    await prefs.setString(
      AppConstants.keyTokenExpiresAt,
      expiresAt.toIso8601String(),
    );
  }

  // ✅ Simpan user data
  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserData, jsonEncode(user.toJson()));
  }

  // ✅ Get token saat ini
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyAuthToken);
  }

  // ✅ Cek apakah user sudah login
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final isValid = await ApiClient().isTokenValid();
    return token != null && isValid;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/user/registeruser'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation':
            password, // Biasanya backend Laravel membutuhkan ini
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Gagal melakukan pendaftaran');
    }
  }
}
