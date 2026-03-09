// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../data/services/post_service.dart';
import '../../data/services/user_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/post_model.dart';
import '../../data/models/user_model.dart';
import '../widgets/post_card.dart';
import '../pages/login_page.dart';
import '../pages/notification_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<PostModel>> _postsFuture;
  final PostService _postService = PostService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  final ApiClient _apiClient = ApiClient();

  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPosts();
    _checkTokenValidity();
  }

  // ✅ Cek validitas token
  Future<void> _checkTokenValidity() async {
    final isValid = await _apiClient.isTokenValid();
    if (!isValid && mounted) {
      await _handleSessionExpired();
    }
  }

  // ✅ Handle session expired
  Future<void> _handleSessionExpired() async {
    await _authService.logout();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi berakhir. Silakan login ulang.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // ✅ Load data user dari cache
  void _loadUserData() {
    final user = _userService.getCurrentUser();
    if (mounted) {
      setState(() {
        // ✅ PERBAIKAN: Uncomment baris ini agar user data muncul di UI
        _currentUser = user;
      });
    }
  }

  // ✅ Load posts
  void _loadPosts() {
    setState(() {
      _postsFuture = _postService.fetchPosts().catchError((error) {
        if (error.toString().contains('SESSION_EXPIRED') ||
            error.toString().contains('401')) {
          _handleSessionExpired();
        }
        throw error;
      });
    });
  }

  // ✅ Navigasi ke notifikasi
  void _navigateToNotifications() async {
    final isValid = await _apiClient.isTokenValid();
    if (!isValid) {
      await _handleSessionExpired();
      return;
    }
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationPage()),
      );
    }
  }

  // lib/presentation/pages/home_page.dart

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8FAFC,
      ), // Background abu sangat muda agar konten stand out
      body: RefreshIndicator(
        onRefresh: () async {
          _loadUserData();
          _loadPosts();
          await _postsFuture.catchError((_) => null);
        },
        color: const Color(0xFF243E8F),
        child: CustomScrollView(
          slivers: [
            // ✅ Modern Header (Tanpa Logo User)
            SliverAppBar(
              expandedHeight: 100,
              floating: true,
              pinned: true,
              elevation: 0,

              automaticallyImplyLeading:
                  false, // Menghapus tombol back otomatis jika ada
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsetsDirectional.only(
                  start: 16,
                  top: 10,
                  bottom: 16,
                ),
                centerTitle: false,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF243E8F), Color(0xFF4A90E2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize
                      .min, // WAJIB agar kolom tidak mengambil ruang sisa
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Text(
                      'SimpeDesa Berita',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ✅ Search Bar yang lebih "Tebal" dan Berwarna
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari kabar desa hari ini...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF243E8F),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
            ),

            // ✅ Post List
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: FutureBuilder<List<PostModel>>(
                future: _postsFuture,
                builder: (context, snapshot) {
                  // ... (Logika Snapsot Tetap Sama)
                  final posts = snapshot.data ?? [];
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PostCard(
                          post: posts[index],
                        ), // Pastikan PostCard Anda menggunakan desain elevasi rendah
                      );
                    }, childCount: posts.length),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🕒 Helper: Greeting
  String _getGreeting() {
    final hour = DateTime.now().hour;
    String timeGreeting;
    if (hour < 11) {
      timeGreeting = 'Selamat Pagi';
    } else if (hour < 15) {
      timeGreeting = 'Selamat Siang';
    } else if (hour < 18) {
      timeGreeting = 'Selamat Sore';
    } else {
      timeGreeting = 'Selamat Malam';
    }
    return '$timeGreeting, ${_currentUser?.name}';
  }

  // ✅ Helper: Initials
  String _getInitials() {
    if (_currentUser == null || _currentUser!.name.isEmpty) return '?';
    final names = _currentUser!.name.trim().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return names[0].substring(0, 1).toUpperCase();
  }

  // 🌫️ Shimmer Loading
  Widget _buildShimmerLoading() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 16,
                  width: double.infinity,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Container(height: 12, width: 200, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
        childCount: 5,
      ),
    );
  }

  // ❌ Error State
  Widget _buildErrorState(String error) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat berita',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.length > 100 ? '${error.substring(0, 100)}...' : error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPosts,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF243E8F),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📭 Empty State
  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.newspaper, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada berita',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Berita terbaru akan muncul di sini',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
