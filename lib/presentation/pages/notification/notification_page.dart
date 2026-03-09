// lib/presentation/pages/notification_page.dart
import 'package:flutter/material.dart';
import 'package:simpedesa/presentation/pages/complaint/complaint_detail_page.dart';
import 'package:simpedesa/presentation/pages/login_and_register/login_page.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/models/notification_model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _service = NotificationService();
  List<NotificationModel> _complaints = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final complaints = await _service.getComplaints();

      print('✅ [UI] Received ${complaints.length} complaints');
      if (complaints.isNotEmpty) {
        print('📋 [UI] First item: ${complaints.first.title}');
      }

      if (mounted) {
        setState(() {
          _complaints = complaints;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ [UI] Load Error: $e');

      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains('SESSION_EXPIRED')
              ? 'Sesi berakhir. Silakan login ulang.'
              : 'Gagal memuat data. Periksa koneksi/server.';
          _isLoading = false;
        });

        if (e.toString().contains('SESSION_EXPIRED')) {
          // Auto redirect to login
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
            (route) => false,
          );
        }
      }
    }
  }

  void _onComplaintTap(NotificationModel complaint) {
    // ✅ Navigate ke halaman chat untuk pengaduan ini
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComplaintDetailPage(
          complaintId: complaint.id,
          complaintTitle: complaint.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgGray,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? _buildErrorState()
                : _complaints.isEmpty
                ? _buildEmptyState()
                : _buildComplaintList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
      decoration: const BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: gold, width: 2),
            ),
            child: const Icon(
              Icons.notifications_active,
              color: primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daftar Pengaduan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Klik untuk lihat detail pengaduan',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadComplaints,
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintList() {
    return RefreshIndicator(
      onRefresh: _loadComplaints,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _complaints.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final complaint = _complaints[index];
          return _ComplaintCard(
            complaint: complaint,
            onTap: () => _onComplaintTap(complaint),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadComplaints,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada pengaduan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajukan pengaduan baru untuk memulai',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // ✅ Warna Theme SimpeDesa
  static const Color primaryBlue = Color(0xFF243E8F);
  static const Color lightBlue = Color(0xFF4A90E2);
  static const Color green = Color(0xFF5CB85C);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bgGray = Color(0xFFF5F7FA);
}

// ✅ Card Pengaduan - Status badge di SAMPING judul
class _ComplaintCard extends StatelessWidget {
  final NotificationModel complaint;
  final VoidCallback onTap;

  const _ComplaintCard({required this.complaint, required this.onTap});

  // ✅ Pindahkan logic warna ke sini (UI Layer)
  Color _getStatusColor(String status) {
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

  IconData _getStatusIcon(String status) {
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

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(complaint.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ HEADER: Judul + Status Badge (sejajar)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul Pengaduan (flexible)
                Expanded(
                  child: Text(
                    complaint.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),

                // ✅ Status Badge (di kanan judul)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(complaint.status),
                        color: statusColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        complaint.statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ✅ Pesan/Deskripsi
            Text(
              complaint.message,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // ✅ Footer: Tanggal + Kategori (tanpa Chat)
            Row(
              children: [
                // 📅 Tanggal
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  complaint.formattedDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),

                // 🏷️ Kategori (jika ada)
                if (complaint.category != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      complaint.category!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
