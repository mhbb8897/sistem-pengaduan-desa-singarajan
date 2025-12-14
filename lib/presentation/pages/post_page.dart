import 'package:flutter/material.dart';
import '../controllers/post_controller.dart';

class PostPage extends StatelessWidget {
  final controller = PostController();

  PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: FutureBuilder(
        future: controller.fetchPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          }

          final posts = snapshot.data as List;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(posts[index].title),
                subtitle: Text(posts[index].body),
              );
            },
          );
        },
      ),
    );
  }
}
