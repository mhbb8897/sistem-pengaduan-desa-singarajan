import '../models/post_model.dart';
import '../services/post_service.dart';

class PostRepository {
  final PostService service = PostService();

  Future<List<PostModel>> getPosts() async {
    return await service.fetchPosts();
  }
}
