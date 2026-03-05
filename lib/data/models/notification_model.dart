class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String status;
  final String time;
  bool isRead; // ✅ Bisa diubah

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.status,
    required this.time,
    this.isRead = false,
  });

  // ✅ Method untuk mark as read
  void markAsRead() {
    isRead = true;
  }

  // ✅ Method untuk mark as unread
  void markAsUnread() {
    isRead = false;
  }

  // ✅ Convert ke JSON untuk disimpan
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'status': status,
      'time': time,
      'isRead': isRead,
    };
  }

  // ✅ Buat dari JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? '',
      time: json['time'] ?? '',
      isRead: json['isRead'] ?? false,
    );
  }
}
