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

  /*
  |--------------------------------------------------------------------------
  | UPDATE PROFILE
  |--------------------------------------------------------------------------
  */
  Future<UserModel> updateProfile({
    required String name,
    required String email,
    String? currentPassword,
    String? password,
    String? passwordConfirmation,
  }) async {
    final body = <String, dynamic>{};

    if (name.trim().isNotEmpty) {
      body['name'] = name.trim();
    }

    if (email.trim().isNotEmpty) {
      body['email'] = email.trim();
    }

    if (currentPassword?.trim().isNotEmpty == true) {
      body['current_password'] = currentPassword!.trim();
    }

    if (password?.trim().isNotEmpty == true) {
      body['password'] = password!.trim();
    }

    if (passwordConfirmation?.trim().isNotEmpty == true) {
      body['password_confirmation'] = passwordConfirmation!.trim();
    }

    final response = await _api.post('user/editprofile', body);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // 1. Ambil data balasan dari server (hanya berisi id, name, email)
      final responseData = data['data'] as Map<String, dynamic>;

      Map<String, dynamic> mergedJson;

      // 2. Gabungkan data baru dengan data user yang lama agar photoUrl, token, dll tidak hilang
      if (_currentUser != null) {
        mergedJson = _currentUser!.toJson();
        responseData.forEach((key, value) {
          mergedJson[key] = value;
        });
      } else {
        mergedJson = responseData;
      }

      // 3. Simpan data yang sudah digabung
      final updatedUser = UserModel.fromJson(mergedJson);
      await setUser(updatedUser);
      return updatedUser;
    }

    // Penanganan Error Validasi dari Laravel
    if (response.statusCode == 422) {
      if (data['errors'] != null) {
        final Map<String, dynamic> errors = data['errors'];
        final List<String> messages = [];

        errors.forEach((key, value) {
          if (value is List) {
            messages.addAll(value.map((e) => e.toString()));
          }
        });

        throw Exception(messages.join('\n'));
      }
    }

    // Penanganan Error Umum Server
    throw Exception(
      data['message'] ?? 'Terjadi kesalahan saat memperbarui profil',
    );
  }
}
