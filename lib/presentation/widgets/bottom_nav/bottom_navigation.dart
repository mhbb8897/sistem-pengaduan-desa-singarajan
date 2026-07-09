import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../pages/home_page/home_page.dart';
import '../../pages/notification/notification_page.dart';
import '../../pages/complaint/complaint_page.dart';
import '../../pages/complaint/mycomplaint_page.dart';
import '../../pages/profile/profile_page.dart';

class BottomNavigationBarExampleApp extends StatefulWidget {
  // ✅ 1. Tambahkan parameter untuk mendeteksi apakah user baru saja login
  final bool justLoggedIn;

  const BottomNavigationBarExampleApp({
    super.key,
    this.justLoggedIn =
        false, // Default false agar aman dipanggil dari mana saja
  });

  Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLogin') ?? false;
  }

  @override
  State<BottomNavigationBarExampleApp> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExampleApp> {
  int _selectedIndex = 0;

  final GlobalKey<MyComplaintPageState> _complaintPageKey =
      GlobalKey<MyComplaintPageState>();

  // ✅ 2. Tambahkan initState untuk memunculkan SnackBar jika justLoggedIn == true
  @override
  void initState() {
    super.initState();

    if (widget.justLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Login Berhasil! Selamat datang."),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _openCreateComplaint() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ComplaintPage()),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {
        _selectedIndex = 2;
      });

      await _complaintPageKey.currentState?.refreshData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text("Pengaduan berhasil dikirim!"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      const NotificationPage(),
      MyComplaintPage(key: _complaintPageKey),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateComplaint,
        backgroundColor: const Color(0xFF243E8F),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildItem(icon: Icons.home_outlined, label: "Beranda", index: 0),
              _buildItem(
                icon: Icons.assignment_outlined,
                label: "Pengaduan",
                index: 2,
              ),
              const SizedBox(width: 40),
              _buildItem(
                icon: Icons.notifications_none,
                label: "Notifikasi",
                index: 1,
              ),
              _buildItem(icon: Icons.person_outline, label: "Profil", index: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final selected = _selectedIndex == index;
    final Color activeColor = const Color(0xFF243E8F);

    return InkResponse(
      onTap: () => _onItemTapped(index),
      radius: 28,
      highlightShape: BoxShape.circle,
      splashColor: activeColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? activeColor : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? activeColor : Colors.grey,
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
