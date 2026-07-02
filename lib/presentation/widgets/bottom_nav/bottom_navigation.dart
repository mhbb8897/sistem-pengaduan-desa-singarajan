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

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = const [
      HomePage(),
      NotificationPage(),
      MyComplaintPage(),
      ProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openCreateComplaint() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ComplaintPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),

      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateComplaint,
        child: const Icon(Icons.add),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),

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

    return InkResponse(
      onTap: () => _onItemTapped(index),
      radius: 28,
      highlightShape: BoxShape.circle,
      splashColor: Colors.deepPurple.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? Colors.deepPurple : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.deepPurple : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
