// ✅ Chat Bubble dengan role badge & styling berbeda untuk admin/user
import 'package:flutter/material.dart';
import 'package:simpedesa/data/models/notification_model.dart';

class _MessageBubble extends StatelessWidget {
  final NotificationModel message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isFromAdmin = message.isFromAdmin;
    final primaryBlue = const Color(0xFF243E8F);
    final gold = const Color(0xFFD4AF37);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isFromAdmin
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFromAdmin) ...[
            // Avatar Petugas
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryBlue, width: 1.5),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
          ],

          // ✅ Message Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: isFromAdmin
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                // Role Badge + Nama
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isFromAdmin) const SizedBox(width: 50),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isFromAdmin
                            ? primaryBlue.withOpacity(0.1)
                            : gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isFromAdmin
                              ? primaryBlue.withOpacity(0.3)
                              : gold.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message.senderName ?? 'Anonymous',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isFromAdmin ? primaryBlue : gold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isFromAdmin ? primaryBlue : gold,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isFromAdmin ? 'PETUGAS' : 'PELAPOR',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // ✅ Bubble Content
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isFromAdmin ? Colors.white : primaryBlue,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isFromAdmin ? 4 : 16),
                      bottomRight: Radius.circular(isFromAdmin ? 16 : 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: isFromAdmin
                        ? Border.all(color: primaryBlue.withOpacity(0.2))
                        : null,
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      color: isFromAdmin ? Colors.grey.shade800 : Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),

                // Timestamp
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                  child: Text(
                    message.formattedDate,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ),
              ],
            ),
          ),

          if (!isFromAdmin) ...[
            const SizedBox(width: 10),
            // Avatar User
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: gold, width: 1.5),
              ),
              child: const Icon(Icons.person, color: Colors.green, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}
