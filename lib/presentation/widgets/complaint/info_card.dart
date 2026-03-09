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
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Informasi Pengaduan",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.white24, height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTile("PELAPOR", "User 1"),
              ), // Bisa diganti data dinamis
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
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }
}
