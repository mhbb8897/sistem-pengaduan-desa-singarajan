import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

class PostService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/news';

  Future<List<PostModel>> fetchPosts() async {
    final response = await http.get(Uri.parse(baseUrl));
    print(response.body);
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List data = body['data'];

      return data.map((e) => PostModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data berita');
    }
  }
}
