// lib/data/services/notification_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';

class NotificationService {
  // ✅ Ganti sesuai device:
  // Emulator Android: 10.0.2.2
  // Physical Device: IP laptop (misal: 192.168.1.100)
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  // ✅ Ambil daftar pengaduan
  Future<List<NotificationModel>> getComplaints() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/complaint_data'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> jsonList = data is List
            ? data
            : (data['data'] ?? data['complaints'] ?? []);

        return jsonList
            .map((json) => NotificationModel.fromComplaintJson(json))
            .toList();
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching complaints: $e');
      rethrow;
    }
  }

  // ✅ Ambil pesan chat untuk pengaduan tertentu
  Future<List<NotificationModel>> getMessages(int complaintId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/complaints/$complaintId/messages'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> jsonList = data is List
            ? data
            : (data['data'] ?? data['messages'] ?? []);

        return jsonList
            .map((json) => NotificationModel.fromMessageJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Error fetching messages: $e');
      return [];
    }
  }

  // ✅ Kirim pesan balasan
  Future<bool> sendMessage(int complaintId, String message) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/complaints/$complaintId/messages'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: json.encode({'message': message}),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Error sending message: $e');
      return false;
    }
  }

  // ✅ Tandai pengaduan sebagai sudah dibaca
  Future<bool> markAsRead(int complaintId) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$_baseUrl/complaints/$complaintId/read'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: json.encode({'is_read': true}),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error marking as read: $e');
      return false;
    }
  }
}
