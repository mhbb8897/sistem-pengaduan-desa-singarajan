import 'dart:convert';

import '../../core/api_client.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiClient _api = ApiClient();

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

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal update profil');
    }

    return UserModel.fromJson(data['data']);
  }
}
