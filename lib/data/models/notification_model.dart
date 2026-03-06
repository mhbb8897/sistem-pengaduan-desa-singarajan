// lib/data/models/notification_model.dart
// ❌ JANGAN import flutter/material.dart di sini

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String status; // 'diajukan', 'diproses', 'selesai'
  final String createdAt;
  final String? category;
  final String? attachmentUrl;

  // Chat fields
  final String? senderName;
  final String? senderRole;
  final bool? isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.status,
    required this.createdAt,
    this.category,
    this.attachmentUrl,
    this.senderName,
    this.senderRole,
    this.isRead,
  });

  // ✅ Factory untuk Complaint
  factory NotificationModel.fromComplaintJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['subject'] ?? 'Tanpa Judul',
      message: json['message'] ?? json['description'] ?? '',
      status: json['status'] ?? 'diajukan',
      createdAt: json['created_at'] ?? json['date'] ?? '',
      category: json['category'],
      attachmentUrl: json['attachment_url'],
      isRead: json['is_read'] ?? false,
    );
  }

  // ✅ Factory untuk Message/Chat
  factory NotificationModel.fromMessageJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: '',
      message: json['message'] ?? '',
      status: 'message',
      createdAt: json['created_at'] ?? '',
      senderName: json['sender_name'] ?? json['user_name'],
      senderRole: json['sender_role'] ?? json['role'],
      isRead: json['is_read'] ?? false,
    );
  }

  // ✅ Helper: Format tanggal
  String get formattedDate {
    try {
      final date = DateTime.parse(createdAt);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return createdAt;
    }
  }

  // ✅ Helper: Status label
  String get statusLabel {
    if (status == 'message') return 'Pesan';
    switch (status.toLowerCase()) {
      case 'selesai':
        return 'Selesai';
      case 'diproses':
        return 'Diproses';
      case 'diajukan':
      default:
        return 'Diajukan';
    }
  }

  // ✅ Helper: Status key untuk UI mapping
  String get statusKey => status.toLowerCase();

  // ✅ Helper: Check if message
  bool get isMessage => status == 'message';

  // ✅ Helper: Check if from admin
  bool get isFromAdmin => senderRole == 'super_admin' || senderRole == 'admin';
}
