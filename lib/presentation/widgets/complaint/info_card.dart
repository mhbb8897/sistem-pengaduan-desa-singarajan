import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';
import 'status_badge.dart';

class ComplaintInfoCard extends StatelessWidget {
  final NotificationModel complaint;

  const ComplaintInfoCard({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Text(
            "Informasi Pengaduan",
            style: TextStyle(
              color: Color(0xFF243E8F), // Menggunakan warna biru tema
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Divider(color: Colors.grey.shade200, height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTile(
                  "PELAPOR",
                  "User 1",
                ), // Bisa diganti data dinamis
              ),
              Expanded(
                child: _buildTile("KATEGORI", complaint.category ?? "-"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: StatusBadge(status: complaint.status)),
              Expanded(
                child: _buildTile("WAKTU LAPORAN", complaint.formattedDate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
