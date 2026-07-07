import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../data/services/user_service.dart';
import '../../../data/models/user_model.dart';
import '../login_and_register/login_page.dart';
// import '../pages/edit_profile_page.dart'; // Uncomment jika sudah ada
// import '../pages/report_history_page.dart'; // Uncomment jika sudah ada

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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

  // ✅ WhatsApp Config
  static const String whatsappNumber =
      '6281234567890'; // Ganti dengan nomor admin
  static const String whatsappMessage =
      'Halo Admin SimpeDesa, saya butuh bantuan mengenai...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _userService.loadUser();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading user: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✅ NAVIGATE TO EDIT PROFILE PAGE (dengan data user)
  void _navigateToEditProfile() {
    // Jika EditProfilePage sudah ada, uncomment baris bawah:
    // Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfilePage(user: _user!)));

    // ✅ Temporary: Show dialog untuk demo edit profile
    _showEditProfileDialog();
  }

  // ✅ DIALOG: Edit Profile dengan API Call
  // ✅ DIALOG: Edit Profile dengan API Call
  void _showEditProfileDialog() {
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: _user?.name);
    final emailController = TextEditingController(text: _user?.email);

    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool _isSubmitting = false;

    // Variabel untuk fitur hide/show password
    bool _obscureOld = true;
    bool _obscureNew = true;
    bool _obscureConfirm = true;

    showDialog(
      context: context,
      builder: (ctx) => MediaQuery(
        data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
        child: StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Edit Profil',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF243E8F),
              ),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Input Nama
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Input Email
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.email_outlined),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Email wajib diisi' : null,
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child:
                          Divider(), // Pemisah antara info umum dan zona password
                    ),

                    // Input Password Lama
                    TextFormField(
                      controller: oldPasswordController,
                      obscureText: _obscureOld,
                      decoration: InputDecoration(
                        labelText: 'Password Lama (Opsional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureOld
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () =>
                              setDialogState(() => _obscureOld = !_obscureOld),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Password Baru (Dengan Alert/Helper & Validasi)
                    // Input Password Baru
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: _obscureNew,
                      decoration: InputDecoration(
                        labelText: 'Password Baru',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.lock_reset),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () =>
                              setDialogState(() => _obscureNew = !_obscureNew),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),

                        // UPDATE: Teks bantuan disesuaikan (tanpa simbol)
                        helperText:
                            'Minimal 8 karakter, wajib ada huruf besar, huruf kecil, dan angka.',
                        helperMaxLines: 2,
                        helperStyle: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;

                        // UPDATE: Regex disamakan persis dengan backend Laravel
                        // (?=.*?[A-Z]) -> Minimal 1 huruf besar
                        // (?=.*?[a-z]) -> Minimal 1 huruf kecil
                        // (?=.*?[0-9]) -> Minimal 1 angka
                        // .{8,}        -> Minimal 8 karakter
                        RegExp regex = RegExp(
                          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$',
                        );
                        if (!regex.hasMatch(v)) {
                          return 'Format password belum sesuai syarat!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Input Konfirmasi Password
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password Baru',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () => setDialogState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (v) {
                        if (newPasswordController.text.isNotEmpty &&
                            v != newPasswordController.text) {
                          return 'Konfirmasi password tidak cocok';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
             ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF243E8F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;

                        if (newPasswordController.text.isNotEmpty &&
                            oldPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Masukkan password lama untuk mengubah password!',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        setDialogState(() => _isSubmitting = true);

                        // PENTING: Simpan reference ScaffoldMessenger sebelum proses async dimulai
                        final scaffoldMessenger = ScaffoldMessenger.of(context);

                        try {
                          final updatedUser = await _userService.updateProfile(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            currentPassword:
                                oldPasswordController.text.trim().isEmpty
                                ? null
                                : oldPasswordController.text.trim(),
                            password: newPasswordController.text.trim().isEmpty
                                ? null
                                : newPasswordController.text.trim(),
                            passwordConfirmation:
                                confirmPasswordController.text.trim().isEmpty
                                ? null
                                : confirmPasswordController.text.trim(),
                          );

                          if (mounted) {
                            setState(() => _user = updatedUser);

                            // Tutup dialog terlebih dahulu
                            Navigator.pop(ctx);

                            // Gunakan variabel yang sudah disimpan di awal untuk memunculkan snackbar
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('✅ Profil berhasil diperbarui'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text('❌ Gagal: ${e.toString()}'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setDialogState(() => _isSubmitting = false);
                          }
                        }
                      },
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Simpan'),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ✅ WHATSAPP: Buka chat langsung
  void _openWhatsApp() async {
    if (_user == null) return;

    final message =
        """
Halo Admin SimpeDesa 👋

Perkenalkan saya:
Nama : ${_user!.name}
Email : ${_user!.email}

Saya membutuhkan bantuan terkait aplikasi SimpeDesa.
Terima kasih.
""";

    final url =
        'https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(message)}';

    final uri = Uri.parse(url);

    if (await launchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp tidak dapat dibuka')),
      );
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
      key: _scaffoldKey,
      backgroundColor: bgGray,
      body: _isLoading
          ? _buildLoading()
          : _user == null
          ? _buildNotLoggedIn()
          : _buildProfileContent(),
    );
  }

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

  Widget _buildProfileContent() {
    return CustomScrollView(
      slivers: [
        // 🔹 Header Gradient
        SliverAppBar(
          expandedHeight: 240,
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: gold, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.white,
                              backgroundImage: _user?.photoUrl != null
                                  ? NetworkImage(_user!.photoUrl!)
                                  : null,
                              child: _user?.photoUrl == null
                                  ? Text(
                                      _getInitials(),
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: primaryBlue,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
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
                  subtitle: 'Ubah nama, email, atau password',
                  iconColor: primaryBlue,
                  onTap: _navigateToEditProfile,
                ),

                // ❌ Keamanan dihapus sesuai request
                const SizedBox(height: 5),

                // ✅ Report Section
                _buildSectionTitle('Pengaduan'),
                _menuCard(
                  icon: Icons.history_outlined,
                  title: 'Riwayat Pengaduan',
                  subtitle: 'Lihat status laporan Anda',
                  iconColor: green,
                  badge: '3',
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportHistoryPage()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur Riwayat Pengaduan segera hadir!'),
                      ),
                    );
                  },
                ),

                // ❌ "Buat Pengaduan Baru" dihapus sesuai request
                const SizedBox(height: 5),

                // ✅ Bantuan Section - WhatsApp Only
                _buildSectionTitle('Bantuan'),
                _buildWhatsAppWidget(),

                const SizedBox(height: 5),

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

  // 💬 WhatsApp Info Widget
  Widget _buildWhatsAppWidget() {
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
          onTap: _openWhatsApp,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // ✅ WhatsApp Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat,
                    color: Color(0xFF25D366),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // ✅ Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hubungi via WhatsApp',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Chat admin untuk bantuan cepat',
                        style: TextStyle(fontSize: 13, color: textGray),
                      ),
                    ],
                  ),
                ),
                // ✅ Badge "Online"
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Online',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🎴 Menu Card Widget (Reusable)
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

  // ✅ Helper: Inisial Nama untuk Avatar
  String _getInitials() {
    if (_user == null) return '?';
    final names = _user!.name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return names[0].substring(0, 1).toUpperCase();
  }
}
