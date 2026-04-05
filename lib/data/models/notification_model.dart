import 'dart:convert';

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String status; // 'diajukan', 'diproses', 'selesai'
  final String createdAt;
  final String? category;
  final String? attachment_url;

  // ✅ Field Tambahan untuk Dynamic Content
  final String? location;
  final String? staffName;
  final String? incidentDate;
  final String? unitName;
  final Map<String, dynamic>
  decryptedContent; // ✅ Menerima JSON object dari server

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
    this.attachment_url,
    this.location,
    this.staffName,
    this.incidentDate,
    this.unitName,
    this.decryptedContent = const {}, // ✅ Default empty map
    this.senderName,
    this.senderRole,
    this.isRead,
  });

  // ✅ Factory untuk Complaint (UPDATED)
  factory NotificationModel.fromComplaintJson(Map<String, dynamic> json) {
    // 🔍 DEBUG: Print untuk melihat kunci apa saja yang masuk dari API
    print("Keys dari API: ${json.keys.toList()}");

    // Cari decrypted_content di berbagai kemungkinan key
    var rawDecrypted =
        json['decrypted_content'] ?? json['raw_decrypted_json'] ?? {};

    Map<String, dynamic> decrypted = {};
    if (rawDecrypted is Map) {
      decrypted = Map<String, dynamic>.from(rawDecrypted);
    } else if (rawDecrypted is String) {
      // Jika ternyata dikirim dalam bentuk string JSON, kita decode
      try {
        decrypted = Map<String, dynamic>.from(jsonDecode(rawDecrypted));
      } catch (_) {}
    }

    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Tanpa Judul',
      message: json['message'] ?? '',
      status: json['status'] ?? 'diajukan',
      createdAt: json['created_at'] ?? '',
      category: json['category'],
      attachment_url: json['attachment_url'],
      isRead: json['is_read'] ?? false,

      // Mapping untuk kemudahan akses langsung
      location: decrypted['lokasi']?.toString(),
      staffName: decrypted['nama_perangkat_desa']?.toString(),
      incidentDate: decrypted['tanggal_dan_waktu_kejadian']?.toString(),
      unitName: decrypted['nama_layanan_unit']?.toString(),

      // ✅ Simpan seluruh data untuk detail_card.dart
      decryptedContent: decrypted,
    );
  }
  // ✅ Factory untuk Message/Chat (Tetap sama)
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
      return '${date.day} ${_monthName(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return createdAt;
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  // ✅ Helper: Ambil value dari decryptedContent dengan aman
  String getDecryptedValue(String key, {String fallback = '-'}) {
    final value = decryptedContent[key];
    if (value == null || value.toString().isEmpty) return fallback;
    return value.toString();
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

  String get statusKey => status.toLowerCase();
  bool get isMessage => status == 'message';

  bool get isFromAdmin {
    return senderRole?.toLowerCase() == 'super_admin';
  }
}
