import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'presentation/pages/login_page.dart';
import 'presentation/widgets/bottom_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> canEnterApp() async {
    final prefs = await SharedPreferences.getInstance();

    final isLogin = prefs.getBool('isLogin') ?? false;
    if (!isLogin) return false;

    final userJson = prefs.getString('user');
    if (userJson == null) return false;
    final user = jsonDecode(userJson);
    if (user['role'] == 'admin') return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: canEnterApp(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return snapshot.data!
              ? const BottomNavigationBarExample()
              : const LoginPage();
        },
      ),
    );
  }
}
