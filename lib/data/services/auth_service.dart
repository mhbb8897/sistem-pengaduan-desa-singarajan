import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_request.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  // ✅ Login ke API
  Future<UserModel> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/loginuser'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(data['user']);
    } else {
      throw Exception(data['message'] ?? 'Login gagal');
    }
  }
}
