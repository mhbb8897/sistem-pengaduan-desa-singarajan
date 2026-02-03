import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      showError('Password dan konfirmasi tidak sama');
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/registeruser'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
          'password_confirmation': confirmPasswordController.text,
        }),
      );

      setState(() => isLoading = false);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil, silakan login'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context); // balik ke login
      } else {
        showError(data['message'] ?? 'Registrasi gagal');
      }
    } catch (e) {
      setState(() => isLoading = false);
      showError('Terjadi kesalahan koneksi');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            children: [
              Image.asset(
                'assets/image/logo-simpedesa.png',
                height: 150,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 12),

              // CARD
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Create your Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // EMAIL
                    TextField(
                      controller: emailController,
                      decoration: inputDecoration('Email'),
                    ),
                    const SizedBox(height: 14),

                    // PASSWORD
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: inputDecoration('Password'),
                    ),
                    const SizedBox(height: 14),

                    // CONFIRM PASSWORD
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: inputDecoration('Confirm Password'),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF243E8F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // DIVIDER
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('or sign up with'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // SOCIAL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        socialButton(Icons.g_mobiledata),
                        const SizedBox(width: 12),
                        socialButton(Icons.facebook),
                        const SizedBox(width: 12),
                        socialButton(Icons.travel_explore),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget socialButton(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 28),
    );
  }
}
