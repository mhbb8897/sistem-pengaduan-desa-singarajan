import 'dart:convert';

import 'package:simpedesa/data/services/secure_storage_service.dart';

import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../models/user_model.dart';

class UserService {
  static final UserService _instance = UserService._internal();

  factory UserService() => _instance;

  UserService._internal() {
    _init();
  }

  final ApiClient _api = ApiClient();

  UserModel? _currentUser;
  bool _isInitialized = false;

  Future<void> _init() async {
    if (_isInitialized) return;

    try {
      final userJson = await SecureStorageService.read(
        AppConstants.keyUserData,
      );

      if (userJson != null) {
        _currentUser = UserModel.fromJson(jsonDecode(userJson));
      }
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

  UserModel? getCurrentUser() => _currentUser;

  Future<void> setUser(UserModel user) async {
    _currentUser = user;
    _isInitialized = true;

    await SecureStorageService.write(
      AppConstants.keyUserData,
      jsonEncode(user.toJson()),
    );
  }

  Future<void> logout() async {
    _currentUser = null;
    _isInitialized = false;

    await SecureStorageService.delete(AppConstants.keyUserData);
  }

  /// Tetap dipertahankan
  Future<UserModel> updateProfile({
    required String name,
    required String email,
    String? password,
  }) async {
    final response = await _api.post('user/editprofile', {
      'name': name,
      'email': email,
      if (password != null && password.isNotEmpty) 'password': password,
    });

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final updatedUser = UserModel.fromJson(data['data']);

      // Update cache + Secure Storage
      await setUser(updatedUser);

      return updatedUser;
    }

    throw Exception(data['message'] ?? 'Gagal update profil');
  }
}
