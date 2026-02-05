import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';

class PostDetailPage extends StatelessWidget {
  final PostModel post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF243E8F),
        title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
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
                  child: const Icon(Icons.broken_image, size: 60),
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔹 CONTENT
                  Text(
                    post.content.isNotEmpty
                        ? post.content
                        : 'Konten belum tersedia.',
                    style: const TextStyle(fontSize: 15, height: 1.7),
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
