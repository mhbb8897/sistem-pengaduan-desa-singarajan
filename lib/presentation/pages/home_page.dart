import 'package:flutter/material.dart';
import '../../data/services/post_service.dart';
import '../../data/services/user_service.dart';
import '../../data/models/post_model.dart';
import '../../data/models/user_model.dart';
import '../widgets/post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<PostModel>> _postsFuture;
  final PostService _postService = PostService();
  final UserService _userService = UserService();

  String _selectedCategory = 'Semua';
  UserModel? _currentUser;

  final List<String> _categories = [
    'Semua',
    'Pemerintahan',
    'Pembangunan',
    'Sosial',
    'Ekonomi',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPosts();
    _ensureUserLoaded();
  }

  Future<void> _ensureUserLoaded() async {
    final user = await _userService.loadUser();
    if (mounted && user != null) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  // ✅ Load data user dari cache (sync)
  void _loadUserData() {
    final user = _userService.getCurrentUser(); // Ambil dari cache memory
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  void _loadPosts() {
    setState(() {
      _postsFuture = _postService.fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadUserData(); // Refresh user data juga
        _loadPosts();
        await _postsFuture;
      },
      color: const Color(0xFF4F46E5),
      child: CustomScrollView(
        slivers: [
          // ✅ SliverAppBar untuk Header
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row(
                //   children: [
                //     Expanded(
                //       child: Text(
                //         _getGreeting(),
                //         style: TextStyle(
                //           color: Colors.grey[600],
                //           fontSize: 14,
                //           fontWeight: FontWeight.w500,
                //         ),
                //         overflow: TextOverflow.ellipsis,
                //       ),
                //     ),
                //     const SizedBox(width: 8),

                //     CircleAvatar(
                //       radius: 14,
                //       backgroundColor: const Color(0xFF4F46E5),
                //       child: Text(
                //         _getInitials(),
                //         style: const TextStyle(
                //           color: Colors.white,
                //           fontSize: 12,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
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
            actions: [
              IconButton(
                icon: Badge(
                  smallSize: 8,
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Colors.grey[700],
                  ),
                ),
                onPressed: () {
                  // Navigasi ke notifikasi
                },
              ),
              const SizedBox(width: 8),
            ],
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
                  // Implement search logic here
                },
              ),
            ),
          ),

          // ✅ Category Chips - ✅ FIXED: Added bottom padding
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 8,
              ), // ✅ Padding bawah agar rapi
              child: SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  // ✅ Tambahkan padding horizontal & bottom
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ).copyWith(bottom: 8),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      selectedColor: const Color(0xFF4F46E5).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF4F46E5),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF4F46E5)
                            : Colors.grey[700],
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF4F46E5)
                              : Colors.grey[300]!,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // ✅ Content List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: FutureBuilder<List<PostModel>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerLoading();
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return _buildEmptyState();
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return PostCard(post: posts[index]);
                  }, childCount: posts.length),
                );
              },
            ),
          ),

          // ✅ Bottom Padding untuk Bottom Navigation
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  // 🕒 Helper untuk Salam Waktu + Nama User
  // String _getGreeting() {
  //   final hour = DateTime.now().hour;
  //   String timeGreeting;

  //   if (hour < 11) {
  //     timeGreeting = 'Selamat Pagi';
  //   } else if (hour < 15) {
  //     timeGreeting = 'Selamat Siang';
  //   } else if (hour < 18) {
  //     timeGreeting = 'Selamat Sore';
  //   } else {
  //     timeGreeting = 'Selamat Malam';
  //   }

  //   if (_currentUser != null) {
  //     return '$timeGreeting, ${_currentUser?.name}';
  //   } else {
  //     return '$timeGreeting, KOSONG';
  //   }
  // }

  // ✅ Ambil Inisial Nama untuk Avatar
  // String _getInitials() {
  //   if (_currentUser == null) return '?';
  //   final names = _currentUser!.name.split(' ');
  //   if (names.length >= 2) {
  //     return '${names[0][0]}${names[1][0]}'.toUpperCase();
  //   }
  //   return names[0].substring(0, 1).toUpperCase();
  // }

  // 🌫️ Shimmer Loading Effect
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
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPosts,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
