import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';

class ComplaintDetailCard extends StatelessWidget {
  final NotificationModel complaint;
  final String title;

  const ComplaintDetailCard({
    super.key,
    required this.complaint,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> content = complaint.decryptedContent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "DETAIL PENGADUAN",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.lock_open, color: Colors.green, size: 16),
            ],
          ),
          const SizedBox(height: 20),

          ..._buildAllDynamicFields(content),

          if (complaint.attachmentUrl != null &&
              complaint.attachmentUrl!.isNotEmpty) ...[
            const Divider(color: Colors.white10, height: 32),
            const Text(
              "BUKTI PENDUKUNG",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // ✅ TAMBAHKAN GestureDetector di sini agar bisa diklik
            GestureDetector(
              onTap: () => _showImagePreview(context, complaint.attachmentUrl!),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  complaint.attachmentUrl!,
                  width: double.infinity,
                  height: 200, // Beri tinggi agar seragam
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.white10,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, color: Colors.white24),
                          SizedBox(height: 4),
                          Text(
                            "Gagal memuat gambar",
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ Fungsi untuk memunculkan Preview Full Screen
  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true, // Klik di luar gambar untuk menutup
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero, // Biar full layar
        child: Stack(
          alignment: Alignment.center,
          children: [
            // InteractiveViewer membuat gambar bisa di-zoom (cubit layar)
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.contain,
              ),
            ),
            // Tombol Tutup di pojok kanan atas
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAllDynamicFields(Map<String, dynamic> content) {
    List<Widget> widgets = [];

    if (content.isEmpty) {
      return [
        const Text(
          "Data detail tidak tersedia",
          style: TextStyle(color: Colors.white54),
        ),
      ];
    }

    content.forEach((key, value) {
      if (value == null || value.toString().trim().isEmpty) return;

      // ✅ FILTER TAMBAHAN:
      // Jangan render jika key mengandung kata 'bukti', 'pendukung', 'attachment', atau 'file'
      // Ini agar nama file mentah dari hasil dekripsi tidak muncul sebagai teks.
      final lowerKey = key.toLowerCase();
      if (lowerKey.contains('bukti') ||
          lowerKey.contains('pendukung') ||
          lowerKey.contains('attachment_path') ||
          lowerKey.contains('file')) {
        return;
      }

      final label = key.replaceAll('_', ' ').toUpperCase();

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
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
              if (key.contains('deskripsi') ||
                  key.contains('kronologi') ||
                  value.toString().length > 50)
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value.toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                )
              else
                Text(
                  value.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
            ],
          ),
        ),
      );
    });

    return widgets;
  }
}
