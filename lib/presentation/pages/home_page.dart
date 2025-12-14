import 'package:flutter/material.dart';
import '../../../';
import 'package:sim';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final PostService service = PostService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PostModel>>(
      future: service.fetchPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan'));
        }

        final posts = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];

            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(post.body),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
