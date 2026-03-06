import 'package:flutter/material.dart';

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String status; // 'diajukan', 'diproses', 'selesai'
  final String createdAt;
  final String? category;
  final String? attachmentUrl;

  // Fields untuk Chat
  final String? senderName;
  final String? senderRole; // 'user' atau 'super_admin'
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

  // ✅ Factory dari JSON API Complaint
  factory NotificationModel.fromComplaintJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['subject'] ?? 'Tanpa Judul',
      message: json['message'] ?? json['description'] ?? '',
      status: json['status'] ?? 'diajukan',
      createdAt: json['created_at'] ?? json['date'] ?? '',
      category: json['category'],
      attachmentUrl: json['attachment_url'],
      senderName: null,
      senderRole: null,
      isRead: json['is_read'] ?? false,
    );
  }

  // ✅ Factory dari JSON API Chat Message
  factory NotificationModel.fromMessageJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: '',
      message: json['message'] ?? '',
      status: 'message',
      createdAt: json['created_at'] ?? '',
      senderName: json['sender_name'] ?? json['user_name'] ?? 'Anonymous',
      senderRole: json['sender_role'] ?? json['role'] ?? 'user',
      isRead: json['is_read'] ?? false,
    );
  }

  // ✅ Helper: Format tanggal
  String get formattedDate {
    try {
      final date = DateTime.parse(createdAt);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return createdAt;
    }
  }

  // ✅ Helper: Status label (hanya 3 status)
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

  // ✅ Helper: Warna status
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'selesai':
        return const Color(0xFF5CB85C); // Green
      case 'diproses':
        return const Color(0xFF4A90E2); // Blue
      case 'diajukan':
      default:
        return const Color(0xFFD4AF37); // Gold
    }
  }

  // ✅ Helper: Icon status
  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Icons.check_circle;
      case 'diproses':
        return Icons.pending_actions;
      case 'diajukan':
      default:
        return Icons.access_time;
    }
  }

  // ✅ Helper: Cek apakah ini pesan chat
  bool get isMessage => status == 'message';

  // ✅ Helper: Cek apakah sender adalah admin/petugas
  bool get isFromAdmin => senderRole == 'super_admin' || senderRole == 'admin';
}
