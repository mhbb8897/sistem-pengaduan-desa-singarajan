import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';

class PostDetailPage extends StatelessWidget {
  final PostModel post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.category),
        backgroundColor: const Color(0xFF243E8F),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 IMAGE
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                post.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 60),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 TITLE
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 🔹 CATEGORY
                  Text(
                    post.category,
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔹 CONTENT
                  Text(
                    post.content.isNotEmpty ? post.content : post.body,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
