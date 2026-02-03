class PostModel {
  final int id;
  final String title;
  final String body;
  final String content;
  final String imageUrl;
  final String category;

  PostModel({
    required this.id,
    required this.title,
    required this.body,
    required this.content,
    required this.imageUrl,
    required this.category,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? 'https://placehold.net/map-400x400.png',
      category: json['category'] ?? 'General',
    );
  }
}
