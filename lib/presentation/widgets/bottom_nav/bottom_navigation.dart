import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../pages/home_page/home_page.dart';
import '../../pages/notification/notification_page.dart';
import '../../pages/complaint/complaint_page.dart';
import '../../pages/complaint/mycomplaint_page.dart';
import '../../pages/profile/profile_page.dart';

class BottomNavigationBarExampleApp extends StatefulWidget {
  const BottomNavigationBarExampleApp({super.key});

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

  // ✅ 1. Buat Key khusus untuk halaman MyComplaintPage
  final GlobalKey<MyComplaintPageState> _complaintPageKey =
      GlobalKey<MyComplaintPageState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ✅ 2. Ubah fungsi ini menjadi async agar bisa menunggu hasil dari ComplaintPage
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
    // ✅ 5. Pindahkan list _pages ke dalam build() agar Key bisa ter-update secara dinamis
    final List<Widget> pages = [
      const HomePage(),
      const NotificationPage(),
      MyComplaintPage(key: _complaintPageKey), // Masukkan Key di sini!
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),

      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateComplaint, // Panggil fungsi yang sudah diubah
        backgroundColor: const Color(
          0xFF243E8F,
        ), // Sesuaikan dengan warna tema jika perlu
        foregroundColor: Colors.white,
        shape: const CircleBorder(), // Pastikan bentuknya bulat sempurna
        child: const Icon(Icons.add, size: 28),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8, // Memberi sedikit jarak elegan antara tombol dan navbar
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
              const SizedBox(width: 40), // Jarak tengah untuk tombol (+)
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
    // Sesuaikan warna selected dengan tema SimpeDesa kamu (Primary Blue)
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
