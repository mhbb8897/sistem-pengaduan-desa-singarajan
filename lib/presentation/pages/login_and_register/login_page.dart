import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpedesa/core/constants.dart';
import 'package:simpedesa/data/models/user_model.dart';
import 'package:simpedesa/data/services/user_service.dart';
import 'package:simpedesa/presentation/widgets/bottom_nav/bottom_navigation.dart';
import 'package:simpedesa/presentation/pages/login_and_register/register_page.dart';
import 'package:simpedesa/data/services/secure_storage_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;

  // ✅ Gunakan key yang SAMA PERSIS dengan ApiClient & AuthService
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';
  static const String _keyExpiresAt = 'token_expires_at';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ✅ Fungsi Login Terintegrasi Sanctum Token
  Future<void> login() async {
    // Validasi form sederhana
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      showError('Email dan password harus diisi');
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1. Kirim Request ke API
      final response = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}/loginuser'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': emailController.text.trim(),
              'password': passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      print(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        // 2. Validasi struktur response
        if (data['data'] == null || data['data']['user'] == null) {
          throw Exception('Format response API tidak valid');
        }

        // 3. Extract User & Token
        final userData = data['data']['user'];
        final token = data['data']['access_token'];
        final hmac_session_key = data['data']['hmac_session_key'];
        final expiresIn =
            data['data']['expires_in'] ??
            AppConstants.tokenExpirationSeconds; // Default 3 jam jika null

        // 4. Convert ke UserModel
        final user = UserModel.fromJson(userData);

        // 5. Simpan Token & Expiration (PENTING)
        await _saveAuthToken(token, hmac_session_key, expiresIn);
        await SecureStorageService.write('hmac_session_key', hmac_session_key);
        // print(prefs.getString('token'));
        // 6. Simpan User Data via UserService
        await UserService().setUser(user);

        // 7. Delay kecil untuk memastikan SharedPreferences tersimpan (mencegah race condition)
        await Future.delayed(const Duration(milliseconds: 200));
        // 8. Navigasi ke Home dengan parameter justLoggedIn
        // 8. Navigasi ke Home dengan parameter justLoggedIn
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const BottomNavigationBarExampleApp(
                justLoggedIn: true, // Tambahkan parameter ini
              ),
            ),
          );
        }
      } else {
        // ✅ BENAR: Else ini sekarang milik if (response.statusCode == 200 ...)
        // Handle error dari backend (401, 422, dll)
        final message = data['message'] ?? 'Login gagal. Silakan coba lagi.';
        showError(message);
      }
    } catch (e) {
      print('❌ [LOGIN ERROR] $e');

      // Handle network error / timeout
      if (e.toString().contains('TimeoutException')) {
        showError('Koneksi timeout. Periksa internet Anda.');
      } else if (e.toString().contains('SocketException')) {
        showError('Tidak ada koneksi internet.');
      } else {
        showError(
          'Terjadi kesalahan: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ✅ Helper: Simpan Token + Expiration Time ke Local Storage
  Future<void> _saveAuthToken(
    String token,
    String hmacKey,
    int expiresIn,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(AppConstants.keyAuthToken, token);
    await prefs.setString(AppConstants.keyHmacSession, hmacKey);
    await prefs.setBool('is_logged_in', true);

    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    await prefs.setString(_keyExpiresAt, expiresAt.toIso8601String());

    print('TOKEN : ${prefs.getString(AppConstants.keyAuthToken)}');
    print('HMAC  : ${prefs.getString(AppConstants.keyHmacSession)}');
  }

  // ✅ Helper: Tampilkan Error SnackBar
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // ✅ Logo SimpeDesa
                  Image.asset(
                    'assets/image/logo-simpedesa.png',
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.admin_panel_settings,
                      size: 80,
                      color: Color(0xFF243E8F),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ✅ Login Card
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade900.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Selamat Datang',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF243E8F),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Silakan login untuk melanjutkan',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ✅ Email Input
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Colors.grey.shade400,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF243E8F),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true)
                              return 'Email wajib diisi';
                            if (!value!.contains('@'))
                              return 'Format email tidak valid';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // ✅ Password Input
                        TextFormField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.grey.shade400,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey.shade400,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF243E8F),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true)
                              return 'Password wajib diisi';
                            if (value!.length < 6)
                              return 'Password minimal 6 karakter';
                            return null;
                          },
                        ),

                        // ✅ Forgot Password (Opsional)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Fitur lupa password akan segera hadir',
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Lupa password?',
                              style: TextStyle(
                                color: Color(0xFF243E8F),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ✅ Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF243E8F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ✅ Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Belum punya akun?',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Daftar sekarang',
                                style: TextStyle(
                                  color: Color(0xFF243E8F),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ✅ Footer
                  Text(
                    'SimpeDesa © ${DateTime.now().year}',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
