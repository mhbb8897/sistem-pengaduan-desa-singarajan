import 'package:flutter/material.dart';
import '../../data/services/notification_service.dart';
import '../../data/models/notification_model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _notifService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    final notifications = await _notifService.getNotifications();

    if (mounted) {
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleTap(NotificationModel notif) async {
    if (!notif.isRead) {
      await _notifService.markAsRead(notif.id);
      await _loadNotifications(); // Refresh UI
    }

    // TODO: Navigate to detail page if needed
    // Navigator.push(context, MaterialPageRoute(...));
  }

  Future<void> _markAllAsRead() async {
    await _notifService.markAllAsRead();
    await _loadNotifications();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua notifikasi sudah dibaca'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgGray,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Header
          _buildHeader(),

          // ✅ List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final unreadCount = _notifService.getUnreadCount();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
      decoration: const BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
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
                      'Notifikasi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Update terbaru untuk Anda',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ✅ Action Buttons
          if (unreadCount > 0) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        '$unreadCount Belum Dibaca',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _markAllAsRead,
                  icon: const Icon(
                    Icons.done_all,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'Tandai Semua',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    backgroundColor: Colors.white.withOpacity(0.2),
                    // bor: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notif = _notifications[index];
        return _NotifCard(
          notif: notif,
          onTap: () => _handleTap(notif),
          primaryBlue: primaryBlue,
          lightBlue: lightBlue,
          green: green,
          gold: gold,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi akan muncul di sini',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // ✅ Warna dari Logo SimpeDesa
  static const Color primaryBlue = Color(0xFF243E8F);
  static const Color lightBlue = Color(0xFF4A90E2);
  static const Color green = Color(0xFF5CB85C);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bgGray = Color(0xFFF5F7FA);
}

// ✅ Card Widget (sama seperti sebelumnya, tambah onTap)
class _NotifCard extends StatelessWidget {
  final NotificationModel notif;
  final VoidCallback onTap;
  final Color primaryBlue;
  final Color lightBlue;
  final Color green;
  final Color gold;

  const _NotifCard({
    required this.notif,
    required this.onTap,
    required this.primaryBlue,
    required this.lightBlue,
    required this.green,
    required this.gold,
  });

  IconData _getStatusIcon() {
    switch (notif.status) {
      case 'Selesai':
        return Icons.check_circle;
      case 'Diproses':
        return Icons.pending_actions;
      case 'Ditolak':
        return Icons.cancel;
      default:
        return Icons.notifications_active;
    }
  }

  Color _getStatusColor() {
    switch (notif.status) {
      case 'Selesai':
        return green;
      case 'Diproses':
        return lightBlue;
      case 'Ditolak':
        return Colors.red.shade400;
      default:
        return gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notif.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isUnread
              ? Border.all(color: primaryBlue.withOpacity(0.3), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: isUnread
                  ? primaryBlue.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isUnread ? 15 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getStatusIcon(), color: _getStatusColor(), size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isUnread
                                ? primaryBlue
                                : Colors.grey.shade800,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.message,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        notif.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getStatusColor().withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          notif.status,
                          style: TextStyle(
                            color: _getStatusColor(),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
