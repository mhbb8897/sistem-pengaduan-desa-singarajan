import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';
import 'status_badge.dart';

class ComplaintInfoCard extends StatelessWidget {
  final NotificationModel complaint;

  const ComplaintInfoCard({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20), // Padding sedikit diperbesar
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Shadow diperhalus
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF243E8F),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                "Informasi Pengaduan",
                style: TextStyle(
                  color: Color(0xFF243E8F),
                  fontWeight: FontWeight.bold,
                  fontSize: 15, // Ukuran font sedikit dinaikkan
                ),
              ),
            ],
          ),

          Divider(color: Colors.grey.shade200, height: 28, thickness: 1),

          // Baris 1: Pelapor & Kategori
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTile(
                  "PELAPOR",
                  complaint.reporterName,
                  Icons.person_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTile(
                  "KATEGORI",
                  complaint.category ?? "-",
                  Icons.category_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Baris 2: Status & Waktu Laporan
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "STATUS",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    StatusBadge(status: complaint.status),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTile(
                  "WAKTU LAPORAN",
                  complaint.formattedDate,
                  Icons.access_time,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Menambahkan parameter ikon untuk mempercantik tile
  Widget _buildTile(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5, // Memberi jarak antar huruf agar elegan
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w600, // Sedikit lebih tebal
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
