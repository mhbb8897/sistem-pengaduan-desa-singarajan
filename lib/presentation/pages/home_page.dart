import 'package:flutter/material.dart';
import '../../data/services/post_service.dart';
import '../../data/models/post_model.dart';
import '../widgets/post_card.dart';

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
    return FutureBuilder<List<PostModel>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return const Center(child: Text('Belum ada berita'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return PostCard(post: posts[index]);
          },
        );
      },
    );
  }
}
