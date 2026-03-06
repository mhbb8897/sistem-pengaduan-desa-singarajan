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

  // ✅ Logout manual
  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadUserData();
        _loadPosts();
        await _postsFuture.catchError((_) => null);
      },
      color: const Color(0xFF243E8F),
      child: CustomScrollView(
        slivers: [
          // ✅ Header
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getGreeting(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _handleLogout,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFF243E8F),
                        child: Text(
                          _getInitials(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Berita Desa',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ✅ Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari berita...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) {
                  // Optional: Implement client-side search
                },
              ),
            ),
          ),

          // ✅ Content List (Tanpa Filter Kategori)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: FutureBuilder<List<PostModel>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerLoading();
                }

                if (snapshot.hasError) {
                  final error = snapshot.error.toString();
                  if (error.contains('SESSION_EXPIRED') ||
                      error.contains('401') ||
                      error.contains('Unauthenticated')) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _handleSessionExpired();
                    });
                    return const SliverToBoxAdapter(child: SizedBox());
                  }
                  return _buildErrorState(error);
                }

                final posts = snapshot.data ?? [];
                if (posts.isEmpty) {
                  return _buildEmptyState();
                }

                // ✅ Tampilkan SEMUA post langsung (tanpa filter)
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final post = posts[index];
                    return PostCard(post: post);
                  }, childCount: posts.length),
                );
              },
            ),
          ),

          // ✅ Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
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
