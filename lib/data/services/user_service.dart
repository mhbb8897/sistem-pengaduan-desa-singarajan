import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpedesa/data/models/user_model.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal() {
    // ✅ Auto-load saat constructor dipanggil
    _initFromStorage();
  }

  UserModel? _currentUser;
  bool _isInitialized = false; // ✅ Flag untuk track initialization
  static const String _keyUserData = 'user_data';

  // ✅ Method internal untuk load dari storage
  Future<void> _initFromStorage() async {
    if (_isInitialized) return; // Jangan load berkali-kali

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_keyUserData);

      if (userJson != null) {
        _currentUser = UserModel.fromJson(jsonDecode(userJson));
        print(
          '✅ [UserService] User loaded from storage: ${_currentUser?.name}',
        );
      }
    } catch (e) {
      print('❌ [UserService] Error init from storage: $e');
    } finally {
      _isInitialized = true;
    }
  }

  // ✅ Public method untuk load user (tunggu initialization)
  Future<UserModel?> loadUser() async {
    // Tunggu sampai initialization selesai
    while (!_isInitialized) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    return _currentUser;
  }

  // ✅ Sinkron (langsung return dari cache)
  UserModel? getCurrentUser() {
    return _currentUser;
  }

  Future<void> setUser(UserModel user) async {
    _currentUser = user;
    _isInitialized = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserData, jsonEncode(user.toJson()));

    print('✅ [UserService] User saved: ${user.name}');
  }

  Future<void> logout() async {
    _currentUser = null;
    _isInitialized = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserData);
    await prefs.remove('isLogin');

    print('✅ [UserService] User logged out');
  }
}
