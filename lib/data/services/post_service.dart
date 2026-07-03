// lib/data/services/post_service.dart
import 'dart:convert';
import '../../core/api_client.dart';
import '../models/post_model.dart';

class PostService {
  final _api = ApiClient();

  Future<List<PostModel>> fetchPosts() async {
    try {
      // 1. Request ke API
      final response = await _api.get('news', requireAuth: true);

      // ✅ DEBUG 1: Cek Status Code & Body Mentah
      print('📡 [DEBUG] Status Code: ${response.statusCode}');
      // print('📦 [DEBUG] Raw Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          // 2. Parsing JSON
          final data = jsonDecode(response.body);

          // ✅ DEBUG 2: Cek Struktur Data Hasil Parsing
          print('🔍 [DEBUG] Parsed Type: ${data.runtimeType}');
          if (data is Map) {
            print('🔑 [DEBUG] Map Keys: ${data.keys.toList()}');
          }

          // 3. Ekstrak List Berita (Handle berbagai format response)
          List<dynamic> jsonList = [];

          if (data is List) {
            // Format A: Langsung List [...]
            jsonList = data;
            print('✅ Format: Direct List');
          } else if (data is Map) {
            // Format B: Wrapper { "success": true, "data": [...] }
            if (data['success'] == true && data['data'] is List) {
              jsonList = data['data'];
              print('✅ Format: Wrapper Success');
            } else if (data['data'] is List) {
              // Format C: { "data": [...] } tanpa success flag
              jsonList = data['data'];
              print('✅ Format: Simple Wrapper');
            } else if (data['data'] is Map && data['data']['news'] is List) {
              // Format D: Nested { "data": { "news": [...] } }
              jsonList = data['data']['news'];
              print('✅ Format: Nested Map');
            }
          }

          // 4. Validasi jika list tetap kosong
          if (jsonList.isEmpty) {
            print(
              '⚠️ [DEBUG] List kosong. Struktur data mungkin tidak dikenali.',
            );
            print('⚠️ [DEBUG] Cek isi "data" manual: ${data['data']}');
            return []; // Return empty list agar tidak crash, tapi UI akan menampilkan empty state
          }

          print('🔄 [DEBUG] Memproses ${jsonList.length} item...');

          // 5. Convert ke Model (Dengan try-catch per item untuk debug)
          final posts = <PostModel>[];
          for (var json in jsonList) {
            try {
              posts.add(PostModel.fromJson(json));
            } catch (e) {
              print('❌ [DEBUG] Gagal parse 1 item: $e');
              print('❌ [DEBUG] Item JSON: $json');
              // Lanjut ke item berikutnya agar tidak gagal total
            }
          }

          print('✅ [DEBUG] Berhasil memuat ${posts.length} posts.');
          return posts;
        } catch (e, stack) {
          // ✅ DEBUG 3: Error saat Parsing JSON
          print('❌ [DEBUG] JSON Parse Error: $e');
          print('📋 [DEBUG] Stack Trace: $stack');
          throw Exception('Gagal memproses data: $e');
        }
      } else {
        // ✅ DEBUG 4: Status Code Bukan 200
        print('❌ [DEBUG] HTTP Error ${response.statusCode}: ${response.body}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e, stack) {
      // ✅ DEBUG 5: Error Network/Umum
      print('❌ [DEBUG] General Error: $e');
      print('📋 [DEBUG] Stack: $stack');
      rethrow;
    }
  }
}
