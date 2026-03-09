import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpedesa/core/constants.dart';
import 'package:simpedesa/data/models/user_model.dart';
import 'package:http/http.dart' as http;

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal() {
    _initFromStorage();
  }

  UserModel? _currentUser;
  bool _isInitialized = false;
  static const String _keyUserData = 'user_data';

  Future<void> _initFromStorage() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_keyUserData);

      if (userJson != null) {
        _currentUser = UserModel.fromJson(jsonDecode(userJson));
        print('✅ [UserService] User loaded: ${_currentUser?.name}');
      }
    } catch (e) {
      print('❌ [UserService] Error init storage: $e');
    } finally {
      _isInitialized = true;
    }
  }

  Future<UserModel?> loadUser() async {
    while (!_isInitialized) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    return _currentUser;
  }

  UserModel? getCurrentUser() {
    return _currentUser;
  }

  Future<void> setUser(UserModel user) async {
    _currentUser = user;
    _isInitialized = true;
    final prefs = await SharedPreferences.getInstance();
    // ✅ Gunakan AppConstants
    await prefs.setString(AppConstants.keyUserData, jsonEncode(user.toJson()));
  }

  Future<void> logout() async {
    _currentUser = null;
    _isInitialized = false;
    final prefs = await SharedPreferences.getInstance();
    // ✅ Hapus semua key yang didefinisikan di Constants
    await prefs.remove(AppConstants.keyUserData);
    await prefs.remove(AppConstants.keyAuthToken);
    await prefs.remove('isLogin');
  }

  // ✅ FIX: Fungsi Update Profile yang sinkron dengan key storage
  Future<UserModel> updateProfile({
    required String name,
    required String email,
    String? password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ GUNAKAN KEY YANG SAMA DENGAN CONSTANTS
    final token = prefs.getString(AppConstants.keyAuthToken);

    if (token == null) throw Exception('Sesi berakhir, silakan login kembali');

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/user/editprofile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        if (password != null && password.isNotEmpty) 'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final updatedUser = UserModel.fromJson(data['data']);

      // ✅ Update cache lokal menggunakan method setUser yang sudah ada
      await setUser(updatedUser);
      return updatedUser;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Gagal update profil');
    }
  }
}
