import 'package:flutter/material.dart';
import '../../data/services/post_service.dart';
import '../../data/models/post_model.dart';

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
          return const Center(child: Text('Gagal memuat data'));
        }

        final posts = snapshot.data!;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(posts[index].title),
                subtitle: Text(posts[index].body),
              ),
            );
          },
        );
      },
    );
  }
}

