import 'package:flutter/material.dart';
import '../../../data/models/complaint_model.dart';

class ComplaintDetailCard extends StatelessWidget {
  final ComplaintModel complaint;
  final String title;

  const ComplaintDetailCard({
    super.key,
    required this.complaint,
    required this.title,
  });

  /// Mapping key JSON -> Label yang ditampilkan
  static const Map<String, String> _fieldLabels = {
    'deskripsi': 'DESKRIPSI',
    'lokasi': 'LOKASI KEJADIAN',
    'nomor_telepon': 'NOMOR TELEPON YANG DAPAT DIHUBUNGI',

    'nama_perangkat_desa': 'NAMA PERANGKAT DESA',
    'nama_layanan_/_unit': 'NAMA LAYANAN / UNIT',
    'nama_layanan_unit': 'NAMA LAYANAN / UNIT',

    'pihak_yang_terlibat': 'PIHAK YANG TERLIBAT',
  };

  String _getLabel(String key) {
    return _fieldLabels[key] ?? key.replaceAll('_', ' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> content = complaint.decryptedContent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "DETAIL PENGADUAN",
                style: TextStyle(
                  color: Color(0xFF243E8F),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Icon(Icons.lock_open, color: Colors.green, size: 16),
            ],
          ),
          const SizedBox(height: 20),

          ..._buildAllDynamicFields(content),

          if (complaint.attachment_url != null &&
              complaint.attachment_url!.isNotEmpty) ...[
            Divider(color: Colors.grey.shade200, height: 32),
            const Text(
              "BUKTI PENDUKUNG UTAMA",
              style: TextStyle(
                color: Color(0xFF243E8F),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () =>
                  _showImagePreview(context, complaint.attachment_url!),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  complaint.attachment_url!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return Container(
                      height: 200,
                      color: Colors.grey.shade100,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, color: Colors.grey.shade400),
                          const SizedBox(height: 4),
                          Text(
                            "Gagal memuat gambar",
                            style: TextStyle(
                              color: Colors.grey.shade500,
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

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
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
        Text(
          "Data detail tidak tersedia",
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ];
    }

    content.forEach((key, value) {
      if (value == null || value.toString().trim().isEmpty) return;

      final lowerKey = key.toLowerCase();

      // Tidak ditampilkan karena sudah memiliki widget khusus
      if (lowerKey.contains('bukti') ||
          lowerKey.contains('pendukung') ||
          lowerKey.contains('attachment_url_path') ||
          lowerKey.contains('file')) {
        return;
      }

      final label = _getLabel(key);

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
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

              if (key == 'deskripsi' ||
                  key == 'kronologi' ||
                  value.toString().length > 50)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    value.toString(),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                )
              else
                Text(
                  value.toString(),
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
            ],
          ),
        ),
      );
    });

    return widgets;
  }
}
