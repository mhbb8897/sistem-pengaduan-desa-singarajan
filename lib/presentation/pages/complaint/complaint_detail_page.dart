import 'package:flutter/material.dart';
import '../../../data/services/complaint_service.dart';
import '../../../data/models/complaint_model.dart';
import '../../../presentation/pages/complaint/complaint_page.dart';

import '../../../core/constants.dart';
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
  final _notifService = ComplaintService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  ComplaintModel? _complaint; // ✅ Variabel ini harus ada di sini
  List<ComplaintModel> _messages = [];
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
    final isClosed = _complaint?.status.toLowerCase() == 'selesai';

    // ✅ Ambil data bukti_pendukung dari JSON terenkripsi
    final String? buktiString =
        _complaint?.decryptedContent?['bukti_pendukung'];
    final List<String> imageList = buktiString != null && buktiString.isNotEmpty
        ? buktiString.split(', ')
        : [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Detail Pengaduan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF243E8F),
        foregroundColor: Colors.white,

        actions: [
          if (_complaint != null &&
              _complaint!.status.toLowerCase() == "diajukan")
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: "Edit Pengaduan",
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ComplaintPage(complaint: _complaint),
                  ),
                );

                if (result == true) {
                  await _loadAllData();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Pengaduan berhasil diperbarui"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
            ),
        ],
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

                          // --- AWAL BLOK DETAIL PENGADUAN ---
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. Detail Informasi Utama (Isi dari DetailCard)
                                ComplaintDetailCard(
                                  complaint: _complaint!,
                                  title: widget.complaintTitle,
                                ),

                                // 2. Pembatas halus jika ada gambar
                                if (imageList.isNotEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Divider(height: 1),
                                  ),

                                // 3. Bagian Bukti Pendukung (Di dalam blok yang sama)
                                if (imageList.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(
                                              Icons.image_outlined,
                                              size: 18,
                                              color: Color(0xFF243E8F),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "BUKTI PENDUKUNG",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF243E8F),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          height:
                                              100, // Ukuran disesuaikan agar compact dalam blok
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: imageList.length,
                                            itemBuilder: (context, index) {
                                              final fileName = imageList[index]
                                                  .trim();
                                              final imageUrl =
                                                  "${AppConstants.baseImageUrl}$fileName";

                                              return GestureDetector(
                                                onTap: () =>
                                                    _showFullImage(imageUrl),
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                    right: 10,
                                                  ),
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade200,
                                                    ),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                        imageUrl,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // --- AKHIR BLOK DETAIL PENGADUAN ---
                        ],

                        const SizedBox(height: 32),
                        // Bagian Percakapan Tetap di luar blok detail
                        const Text(
                          "PERCAKAPAN",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            letterSpacing: 1.2,
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

  // ✅ HELPER: Fungsi untuk melihat foto ukuran penuh
  void _showFullImage(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(url, fit: BoxFit.contain),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
