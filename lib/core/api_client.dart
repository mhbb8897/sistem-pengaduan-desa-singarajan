// lib/core/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class ApiClient {
  // ✅ Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // ✅ Helper: Get token dari storage
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyAuthToken);
  }

  // ✅ Helper: Get headers dengan Authorization
  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (requireAuth) {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        // ✅ Trim token & format Bearer yang benar
        headers['Authorization'] = 'Bearer ${token.trim()}';
        print('🔐 [AUTH] Header: Bearer ${token.trim().substring(0, 10)}...');
      }
    }

    if (requireAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ✅ GET Request
  Future<http.Response> get(String endpoint, {bool requireAuth = true}) async {
    final response = await http
        .get(
          Uri.parse('${AppConstants.baseUrl}/$endpoint'),
          headers: await _getHeaders(requireAuth: requireAuth),
        )
        .timeout(const Duration(seconds: 15));

    await _handleAuthError(response);
    return response;
  }

  // ✅ POST Request
  Future<http.Response> post(
    String endpoint,
    dynamic body, {
    bool requireAuth = true,
  }) async {
    final response = await http
        .post(
          Uri.parse('${AppConstants.baseUrl}/$endpoint'),
          headers: await _getHeaders(requireAuth: requireAuth),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));

    await _handleAuthError(response);
    return response;
  }

  // ✅ PATCH Request
  Future<http.Response> patch(
    String endpoint,
    dynamic body, {
    bool requireAuth = true,
  }) async {
    final response = await http
        .patch(
          Uri.parse('${AppConstants.baseUrl}/$endpoint'),
          headers: await _getHeaders(requireAuth: requireAuth),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));

    await _handleAuthError(response);
    return response;
  }

  // ✅ Handle 401 Unauthorized → Auto Logout
  Future<void> _handleAuthError(http.Response response) async {
    if (response.statusCode == 401) {
      await _forceLogout();
      throw Exception('SESSION_EXPIRED');
    }
  }

  // ✅ Force logout: clear storage + redirect (via exception)
  Future<void> _forceLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAuthToken);
    await prefs.remove(AppConstants.keyUserData);
    await prefs.remove(AppConstants.keyTokenExpiresAt);
  }

  // ✅ Helper: Cek apakah token masih valid (berdasarkan waktu)
  Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAt = prefs.getString(AppConstants.keyTokenExpiresAt);

    if (expiresAt == null) return false;

    final expiry = DateTime.parse(expiresAt);
    return DateTime.now().isBefore(expiry);
  }
}
