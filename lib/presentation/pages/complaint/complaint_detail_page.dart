import 'package:flutter/material.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/models/notification_model.dart';

// ✅ Import Widget yang sudah dipisah
import '../../widgets/complaint/info_card.dart';
import '../../widgets/complaint/detail_card.dart';
import '../../widgets/complaint/chat_bubble.dart';
import '../../widgets/complaint/chat_input.dart';
import '../../widgets/complaint/closed_banner.dart';

class ComplaintDetailPage extends StatefulWidget {
  final int complaintId;
  final String complaintTitle;

  const ComplaintDetailPage({
    super.key,
    required this.complaintId,
    required this.complaintTitle,
  });

  @override
  State<ComplaintDetailPage> createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends State<ComplaintDetailPage> {
  final _notifService = NotificationService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  NotificationModel? _complaint; // ✅ Variabel ini harus ada di sini
  List<NotificationModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadComplaintDetail(), _loadMessages()]);
    setState(() => _isLoading = false);
    _scrollToBottom();
  }

  Future<void> _loadComplaintDetail() async {
    try {
      final complaints = await _notifService.getComplaints();
      final complaint = complaints.firstWhere(
        (c) => c.id == widget.complaintId,
        orElse: () => throw Exception('Pengaduan tidak ditemukan'),
      );
      if (mounted) setState(() => _complaint = complaint);
    } catch (e) {
      debugPrint('Error detail: $e');
    }
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _notifService.getMessages(widget.complaintId);
      if (mounted) setState(() => _messages = messages);
    } catch (e) {
      debugPrint('Error messages: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    setState(() => _isSending = true);
    try {
      final success = await _notifService.sendMessage(
        widget.complaintId,
        _messageController.text.trim(),
      );
      if (success && mounted) {
        _messageController.clear();
        await _loadMessages();
        _scrollToBottom();
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Mengakses variabel _complaint dengan aman
    final isClosed = _complaint?.status.toLowerCase() == 'selesai';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Detail Pengaduan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF243E8F),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_complaint != null) ...[
                          ComplaintInfoCard(complaint: _complaint!),
                          const SizedBox(height: 20),
                          ComplaintDetailCard(
                            complaint: _complaint!,
                            title: widget.complaintTitle,
                          ),
                        ],
                        const SizedBox(height: 24),
                        const Text(
                          "PERCAKAPAN",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) =>
                              ChatBubble(message: _messages[index]),
                        ),
                      ],
                    ),
                  ),
                ),
                isClosed
                    ? const ClosedBanner()
                    : ChatInput(
                        controller: _messageController,
                        isSending: _isSending,
                        onSend: _sendMessage,
                      ),
              ],
            ),
    );
  }
}
