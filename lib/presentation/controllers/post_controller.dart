import '../../data/repositories/post_repository.dart';
import '../../data/models/post_model.dart';

class PostController {
  final PostRepository repository = PostRepository();

  Future<List<PostModel>> fetchPosts() {
    return repository.getPosts();
  }
}
