class PostModel {
  final int id;
  final String title;
  final String content;
  final String imageUrl;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['image_url'],
    );
  }
}
