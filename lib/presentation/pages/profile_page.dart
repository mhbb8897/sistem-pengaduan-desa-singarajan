import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/user_service.dart';
import '../../data/models/user_model.dart';
import '../pages/login_page.dart';
// import '../pages/edit_profile_page.dart'; // Uncomment jika sudah ada
// import '../pages/report_history_page.dart'; // Uncomment jika sudah ada

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _userService = UserService();
  UserModel? _user;
  bool _isLoading = true;

  // ✅ Warna Tema SimpeDesa
  static const Color primaryBlue = Color(0xFF243E8F);
  static const Color lightBlue = Color(0xFF4A90E2);
  static const Color green = Color(0xFF5CB85C);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bgGray = Color(0xFFF5F7FA);
  static const Color textDark = Color(0xFF2D3748);
  static const Color textGray = Color(0xFF718096);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      // Load dari cache atau storage
      final user = await _userService.loadUser();

      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading user: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout, size: 48, color: primaryBlue),
            const SizedBox(height: 16),
            const Text(
              'Keluar dari akun?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu harus login kembali untuk mengakses aplikasi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textGray),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textGray,
                      side: BorderSide(color: textGray.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Keluar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirm != true) return;

    try {
      // ✅ Logout via UserService
      await _userService.logout();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('❌ Error logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal logout, silakan coba lagi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGray,
      body: _isLoading
          ? _buildLoading()
          : _user == null
          ? _buildNotLoggedIn()
          : _buildProfileContent(),
    );
  }

  // 🔄 Loading State
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryBlue),
          SizedBox(height: 16),
          Text('Memuat profil...', style: TextStyle(color: textGray)),
        ],
      ),
    );
  }

  // ❌ Not Logged In State
  Widget _buildNotLoggedIn() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 80, color: textGray.withOpacity(0.5)),
            const SizedBox(height: 24),
            const Text(
              'Belum Login',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan login untuk mengakses profil Anda',
              textAlign: TextAlign.center,
              style: TextStyle(color: textGray),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text(
                  'Login Sekarang',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Main Profile Content
  Widget _buildProfileContent() {
    return CustomScrollView(
      slivers: [
        // 🔹 Header dengan Gradient
        SliverAppBar(
          expandedHeight: 220,
          floating: false,
          pinned: true,
          backgroundColor: primaryBlue,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryBlue, lightBlue],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // ✅ Avatar dengan Border Gold
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: gold, width: 3),
                            ),
                            // child: CircleAvatar(
                            //   radius: 45,
                            //   backgroundColor: Colors.white,
                            //   backgroundImage: _user?.photoUrl != null
                            //       ? NetworkImage(_user!.photoUrl!)
                            //       : null,
                            //   child: _user?.photoUrl == null
                            //       ? Text(
                            //           _getInitials(),
                            //           style: const TextStyle(
                            //             fontSize: 32,
                            //             fontWeight: FontWeight.bold,
                            //             color: primaryBlue,
                            //           ),
                            //         )
                            //       : null,
                            // ),
                          ),
                          // ✅ Edit Photo Badge
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: gold,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ✅ User Info
                      Text(
                        _user?.name ?? 'Pengguna',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _user?.email ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // 🔹 Menu Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ✅ Account Section
                _buildSectionTitle('Akun Saya'),
                _menuCard(
                  icon: Icons.person_outline,
                  title: 'Edit Profil',
                  subtitle: 'Ubah nama, email, atau foto',
                  iconColor: primaryBlue,
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur Edit Profil segera hadir!'),
                      ),
                    );
                  },
                ),
                _menuCard(
                  icon: Icons.security_outlined,
                  title: 'Keamanan',
                  subtitle: 'Ganti password & pengaturan privasi',
                  iconColor: primaryBlue,
                  onTap: () {},
                ),

                const SizedBox(height: 20),

                // ✅ Report Section
                _buildSectionTitle('Pengaduan'),
                _menuCard(
                  icon: Icons.history_outlined,
                  title: 'Riwayat Pengaduan',
                  subtitle: 'Lihat status laporan Anda',
                  iconColor: green,
                  badge: '3', // Contoh: ada 3 pengaduan aktif
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportHistoryPage()));
                  },
                ),
                _menuCard(
                  icon: Icons.add_circle_outline,
                  title: 'Buat Pengaduan Baru',
                  subtitle: 'Laporkan masalah di desa Anda',
                  iconColor: gold,
                  onTap: () {
                    // Navigator.pushNamed(context, '/report');
                  },
                ),

                const SizedBox(height: 20),

                // ✅ Support Section
                _buildSectionTitle('Bantuan'),
                _menuCard(
                  icon: Icons.help_outline,
                  title: 'Pusat Bantuan',
                  subtitle: 'FAQ & panduan penggunaan',
                  iconColor: textGray,
                  onTap: () {},
                ),
                _menuCard(
                  icon: Icons.chat_bubble_outline,
                  title: 'Hubungi Kami',
                  subtitle: 'Kirim pesan ke admin',
                  iconColor: textGray,
                  onTap: () {},
                ),

                const SizedBox(height: 32),

                // ✅ Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Keluar dari Akun',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // ✅ App Version
                const SizedBox(height: 24),
                Text(
                  'SimpeDesa v1.0.0',
                  style: TextStyle(
                    color: textGray.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 📋 Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textGray,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // 🎴 Menu Card Widget
  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // ✅ Icon Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),

                // ✅ Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primaryBlue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: textGray),
                      ),
                    ],
                  ),
                ),

                // ✅ Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: textGray.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Helper: Ambil Inisial Nama untuk Avatar
  String _getInitials() {
    if (_user == null) return '?';
    final names = _user!.name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return names[0].substring(0, 1).toUpperCase();
  }
}
