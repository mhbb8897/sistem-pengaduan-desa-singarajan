import 'package:flutter/material.dart';
import '../../../data/models/complaint_model.dart';
import '../../../core/constants.dart'; // ✅ Pastikan import ini ada untuk baseImageUrl

class ComplaintDetailCard extends StatelessWidget {
  final ComplaintModel complaint;
  final String title;

  const ComplaintDetailCard({
    super.key,
    required this.complaint,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> content = complaint.decryptedContent;

    // ✅ PERBAIKAN: Parsing bukti_pendukung dari String ke List
    // Karena format data di DB Anda adalah "file1.png, file2.png"
    final String? buktiString = content['bukti_pendukung'];
    final List<String> imageList = buktiString != null && buktiString.isNotEmpty
        ? buktiString.split(', ')
        : [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Tema Gelap sesuai kode Anda
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

          // Render field seperti Deskripsi, Lokasi, dll
          ..._buildAllDynamicFields(content),

          // ✅ BAGIAN BUKTI PENDUKUNG (Sekarang terintegrasi di dalam Card)
          if (imageList.isNotEmpty) ...[
            const Divider(color: Colors.white10, height: 32),
            const Row(
              children: [
                Icon(Icons.image_outlined, size: 14, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  "BUKTI PENDUKUNG",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // GRID LAYOUT untuk multiple files
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 kolom sesuai desain Anda
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: imageList.length,
              itemBuilder: (context, index) {
                final fileName = imageList[index].trim();
                // ✅ Gunakan URL lengkap dari storage/record/
                final String imageUrl = "${AppConstants.baseImageUrl}$fileName";

                return _buildFileCard(
                  context,
                  imageUrl,
                  fileName,
                  index,
                  imageList,
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileCard(
    BuildContext context,
    String imageUrl,
    String filename,
    int index,
    List<String> allImages,
  ) {
    return GestureDetector(
      onTap: () => _showImagePreview(context, index, allImages),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white24,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: const BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: Text(
                filename,
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(
    BuildContext context,
    int initialIndex,
    List<String> images,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: images.length,
              controller: PageController(initialPage: initialIndex),
              itemBuilder: (context, index) {
                final url =
                    "${AppConstants.baseImageUrl}${images[index].trim()}";
                return InteractiveViewer(
                  child: Image.network(url, fit: BoxFit.contain),
                );
              },
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
    content.forEach((key, value) {
      if (value == null || value.toString().isEmpty) return;

      // Filter agar bukti_pendukung tidak muncul sebagai teks mentah
      if (key.toLowerCase() == 'bukti_pendukung') return;

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
