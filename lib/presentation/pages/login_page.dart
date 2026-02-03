import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpedesa/presentation/widgets/bottom_navigation.dart';
import 'package:simpedesa/presentation/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/loginuser'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      setState(() => isLoading = false);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLogin', true);
        await prefs.setString('user', jsonEncode(data['user']));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BottomNavigationBarExampleApp()),
        );
      } else {
        showError(data['message'] ?? 'Login gagal');
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Logo
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
                      'Login to your Account',
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
                    const SizedBox(height: 24),

                    // BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? () {} : login, // ⬅ JANGAN null
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
                                'Sign in',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text("Don't have an account? Sign up"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // DIVIDER
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('or sign in with'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    // SOCIAL LOGIN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        socialButton(Icons.g_mobiledata),
                        const SizedBox(width: 12),
                        socialButton(Icons.facebook),
                        const SizedBox(width: 12),
                        socialButton(Icons.travel_explore), // Twitter-like
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
