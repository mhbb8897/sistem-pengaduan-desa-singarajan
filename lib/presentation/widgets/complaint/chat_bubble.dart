import 'package:flutter/material.dart';
import '../../../data/models/complaint_model.dart';

class ChatBubble extends StatelessWidget {
  final ComplaintModel message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isAdmin = message.isFromAdmin;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Selaraskan dengan warna AppBar (Admin) dan warna Kirim (User)
        color: isAdmin ? const Color(0xFF243E8F) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                message.senderName ?? (isAdmin ? "Petugas" : "Anda"),
                style: TextStyle(
                  color: isAdmin ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isAdmin ? "PETUGAS" : "ANDA",
                  style: TextStyle(
                    color: isAdmin ? Colors.white : const Color(0xFF243E8F),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            message.message,
            style: TextStyle(
              color: isAdmin ? Colors.white : Colors.black87,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message.formattedDate,
            style: TextStyle(
              color: isAdmin ? Colors.white70 : Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
