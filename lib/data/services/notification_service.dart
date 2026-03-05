import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  List<NotificationModel> _notifications = [];
  static const String _keyNotifications = 'notifications';

  // ✅ Load notifikasi dari storage
  Future<List<NotificationModel>> getNotifications() async {
    if (_notifications.isNotEmpty) {
      return _notifications;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final notifJson = prefs.getStringList(_keyNotifications);

      if (notifJson != null && notifJson.isNotEmpty) {
        _notifications = notifJson
            .map((json) => NotificationModel.fromJson(jsonDecode(json)))
            .toList();
      } else {
        // ✅ Data dummy jika belum ada
        _notifications = _getDummyNotifications();
        await _saveToStorage();
      }
    } catch (e) {
      debugPrint('❌ Error loading notifications: $e');
      _notifications = _getDummyNotifications();
    }

    return _notifications;
  }

  // ✅ Mark single notification as read
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].markAsRead();
      await _saveToStorage();
      debugPrint('✅ Notification $id marked as read');
    }
  }

  // ✅ Mark all as read
  Future<void> markAllAsRead() async {
    for (var notif in _notifications) {
      notif.markAsRead();
    }
    await _saveToStorage();
    debugPrint('✅ All notifications marked as read');
  }

  // ✅ Get unread count
  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  // ✅ Save to SharedPreferences
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _notifications
          .map((n) => jsonEncode(n.toJson()))
          .toList();
      await prefs.setStringList(_keyNotifications, jsonList);
    } catch (e) {
      debugPrint('❌ Error saving notifications: $e');
    }
  }

  // ✅ Dummy data untuk testing
  List<NotificationModel> _getDummyNotifications() {
    return [
      NotificationModel(
        id: '1',
        title: 'Pengaduan Diproses',
        message: 'Laporan fasilitas jalan sedang ditindaklanjuti',
        status: 'Diproses',
        time: '10 menit lalu',
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: 'Pengaduan Selesai',
        message: 'Pengaduan layanan publik telah diselesaikan',
        status: 'Selesai',
        time: '1 jam lalu',
        isRead: false,
      ),
      NotificationModel(
        id: '3',
        title: 'Pengaduan Ditolak',
        message: 'Bukti pendukung tidak valid',
        status: 'Ditolak',
        time: 'Kemarin',
        isRead: true,
      ),
      NotificationModel(
        id: '4',
        title: 'Pengaduan Baru Diterima',
        message: 'Terima kasih telah melaporkan, admin akan segera meninjau',
        status: 'Baru',
        time: '2 jam lalu',
        isRead: false,
      ),
    ];
  }

  // ✅ Clear all (untuk logout)
  Future<void> clearAll() async {
    _notifications.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyNotifications);
  }
}
