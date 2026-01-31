import 'package:flutter/material.dart';
import '../../data/services/post_service.dart';
import '../../data/models/post_model.dart';
import '../../presentation/widgets/post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<PostModel>> _postsFuture;
  final PostService service = PostService();

  @override
  void initState() {
    super.initState();
    _postsFuture = service.fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔹 HEADER
          const Text(
            'Beranda',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Berita terbaru hari ini',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),

          // 🔹 CONTENT
          Expanded(
            child: FutureBuilder<List<PostModel>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final posts = snapshot.data!;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return PostCard(post: posts[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
