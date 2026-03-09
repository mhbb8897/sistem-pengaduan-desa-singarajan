import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppInfo extends StatelessWidget {
  const WhatsAppInfo({super.key});

  void _launchWA() async {
    final url = Uri.parse("https://wa.me/6281234567890"); // Ganti nomor desa
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.videocam_off_outlined, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ingin mengirim bukti berupa video?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                InkWell(
                  onTap: _launchWA,
                  child: const Text(
                    "Silakan kirim ke WA Admin Desa Singarajan",
                    style: TextStyle(
                      color: Colors.green,
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
