// lib/data/services/notification_service.dart
import 'dart:convert';
import '../models/notification_model.dart';
import '../../core/api_client.dart';

class NotificationService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';
  final _apiClient = ApiClient();

  // ✅ GET Complaints (dengan DEBUG LOG)
  Future<List<NotificationModel>> getComplaints() async {
    try {
      print('🔗 [NOTIF] Request: GET $_baseUrl/complaint_data');

      final response = await _apiClient.get('complaint_data');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          // ✅ DEBUG 2: Struktur parsed
          print('🔍 [NOTIF] Parsed Type: ${data.runtimeType}');
          if (data is Map) {
            print('🔑 [NOTIF] Keys: ${data.keys.toList()}');
          }

          // Handle berbagai format response
          List<dynamic> jsonList = [];

          if (data is List) {
            jsonList = data;
            print('✅ Format: Direct List');
          } else if (data['success'] == true && data['data'] is List) {
            jsonList = data['data'];
            print('✅ Format: Wrapper Success');
          } else if (data['data'] is List) {
            jsonList = data['data'];
            print('✅ Format: Simple Wrapper');
          } else if (data['complaints'] is List) {
            jsonList = data['complaints'];
            print('✅ Format: Complaints Key');
          }

          if (jsonList.isEmpty) {
            print('⚠️ [NOTIF] List kosong. Data: ${data}');
            return [];
          }

          print('🔄 [NOTIF] Parsing ${jsonList.length} items...');

          // Parse ke Model dengan error handling per item
          final complaints = <NotificationModel>[];
          for (var json in jsonList) {
            try {
              complaints.add(NotificationModel.fromComplaintJson(json));
            } catch (e) {
              print('❌ [NOTIF] Gagal parse 1 item: $e');
            }
          }

          print('✅ [NOTIF] Berhasil: ${complaints.length} complaints');
          return complaints;
        } catch (e) {
          throw Exception('Gagal parse JSON: $e');
        }
      } else if (response.statusCode == 401) {
        print('❌ [NOTIF] Unauthorized (401) - Token invalid/expired');
        throw Exception('SESSION_EXPIRED');
      } else {
        print('❌ [NOTIF] HTTP ${response.statusCode}: ${response.body}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e, stack) {
      print('❌ [NOTIF] General Error: $e');
      print('📋 [NOTIF] Stack: $stack');
      rethrow;
    }
  }

  // ✅ GET Messages (Chat) - juga dengan debug
  Future<List<NotificationModel>> getMessages(int complaintId) async {
    try {
      print(
        '🔗 [CHAT] Request: GET $_baseUrl/complaints/$complaintId/messages',
      );

      final response = await _apiClient.get('complaints/$complaintId/messages');

      print('📡 [CHAT] Status: ${response.statusCode}');
      print('📦 [CHAT] Raw Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> jsonList = [];

        if (data is List) {
          jsonList = data;
        } else if (data['data'] is List) {
          jsonList = data['data'];
        } else if (data['messages'] is List) {
          jsonList = data['messages'];
        }

        return jsonList
            .map((json) => NotificationModel.fromMessageJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ [CHAT] Error: $e');
      return [];
    }
  }

  // ✅ POST Send Message
  Future<bool> sendMessage(int complaintId, String message) async {
    try {
      print(
        '🔗 [CHAT] Request: POST $_baseUrl/complaints/$complaintId/messages',
      );
      print('📤 [CHAT] Body: {"message": "$message"}');

      final response = await _apiClient.post(
        'complaints/$complaintId/messages',
        {'message': message},
      );

      print('📡 [CHAT] Response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ [CHAT] Send Error: $e');
      return false;
    }
  }

  // // ✅ Mark as Read
  // Future<bool> markAsRead(int complaintId) async {
  //   try {
  //     final response = await http
  //         .patch(
  //           Uri.parse('$_baseUrl/complaints/$complaintId/read'),
  //           headers: await _getHeaders(),
  //           body: json.encode({'is_read': true}),
  //         )
  //         .timeout(const Duration(seconds: 10));

  //     return response.statusCode == 200;
  //   } catch (e) {
  //     print('❌ [NOTIF] Mark Read Error: $e');
  //     return false;
  //   }
  // }
}
