// lib/core/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpedesa/core/hmac_helper.dart';
import '../core/constants.dart';

class ApiClient {
  // ✅ Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // ✅ Helper: Get token dari storage
  // Future<String?> _getToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(AppConstants.keyAuthToken);
  // }

  // ✅ Helper: Get headers dengan Authorization
  Future<Map<String, String>> _getHeaders({
    String body = '',
    bool requireAuth = true,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (!requireAuth) {
      return headers;
    }

    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString(AppConstants.keyAuthToken);
    final hmacKey = prefs.getString('hmac_session_key');

    print('========== STORAGE ==========');
    print('TOKEN    : $token');
    print('HMAC KEY : $hmacKey');
    print('=============================');

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${token.trim()}';
    }

    if (hmacKey != null && hmacKey.isNotEmpty) {
      final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
          .toString();

      final signature = generateHmacSignature(
        timestamp: timestamp,
        body: body,
        secretKey: hmacKey,
      );

      headers['X-TIMESTAMP'] = timestamp;
      headers['X-SIGNATURE'] = signature;

      print('========== HMAC ==========');
      print('BODY      : $body');
      print('PAYLOAD   : $timestamp$body');
      print('SIGNATURE : $signature');
      print('==========================');
    }

    print('========== HEADERS ==========');
    print(headers);
    print('=============================');

    return headers;
  }

  // ✅ GET Request
  Future<http.Response> get(String endpoint, {bool requireAuth = true}) async {
    final headers = await _getHeaders(requireAuth: requireAuth);

    print(headers);

    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/$endpoint'),
      headers: headers,
    );
    // final response = await http
    //     .get(
    //       Uri.parse('${AppConstants.baseUrl}/$endpoint'),
    //       headers: await _getHeaders(requireAuth: requireAuth),
    //     )
    //     .timeout(const Duration(seconds: 15));

    print('========================');
    print('URL      : ${response.request?.url}');
    print('STATUS   : ${response.statusCode}');
    print('HEADERS  : ${response.headers}');
    print('========================');

    await _handleAuthError(response);
    return response;
  }

  // ✅ POST Request
  Future<http.Response> post(
    String endpoint,
    dynamic body, {
    bool requireAuth = true,
  }) async {
    final encodedBody = jsonEncode(body);
    final response = await http
        .post(
          Uri.parse('${AppConstants.baseUrl}/$endpoint'),
          headers: await _getHeaders(
            body: encodedBody,
            requireAuth: requireAuth,
          ),
          body: encodedBody,
        )
        .timeout(const Duration(seconds: 15));

    print('========================');
    print('URL      : ${response.request?.url}');
    print('STATUS   : ${response.statusCode}');
    print('HEADERS  : ${response.headers}');
    print('========================');

    await _handleAuthError(response);
    return response;
  }

  // ✅ PATCH Request
  Future<http.Response> patch(
    String endpoint,
    dynamic body, {
    bool requireAuth = true,
  }) async {
    final encodedBody = jsonEncode(body);
    final response = await http
        .patch(
          Uri.parse('${AppConstants.baseUrl}/$endpoint'),
          headers: await _getHeaders(
            body: encodedBody,
            requireAuth: requireAuth,
          ),
          body: encodedBody,
        )
        .timeout(const Duration(seconds: 15));

    print('========================');
    print('URL      : ${response.request?.url}');
    print('STATUS   : ${response.statusCode}');
    print('HEADERS  : ${response.headers}');
    print('========================');

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
