import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simpedesa/core/constants.dart';
import '../widgets/report/whatsapp_info.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _judul = TextEditingController();
  final _lokasi = TextEditingController();
  final _deskripsi = TextEditingController();
  final Map<String, TextEditingController> _dynamicControllers = {};

  String _kategori = 'Fasilitas';
  bool _isLoading = false;
  final List<File> _files = [];
  final _picker = ImagePicker();

  // ✅ WARNA TEMA SimpeDesa (Sesuai Logo)
  static const Color primaryBlue = Color(0xFF243E8F);
  static const Color lightBlue = Color(0xFF4A90E2);
  static const Color accentGreen = Color(0xFF5CB85C);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color bgGray = Color(0xFFF5F7FA);
  static const Color textDark = Color(0xFF2D3748);
  static const Color textGray = Color(0xFF718096);

  // Aturan Validasi
  static const int _maxFileSize = 5 * 1024 * 1024; // 5 MB
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png'];

  final Map<String, List<Map<String, dynamic>>> kategoriFields = {
    'Fasilitas': [],
    'Kinerja Perangkat Desa': [
      {
        'label': 'Nama Perangkat Desa',
        'icon': Icons.person_outline,
        'type': 'nama',
      },
    ],
    'Layanan Publik': [
      {
        'label': 'Nama Layanan / Unit',
        'icon': Icons.account_balance_outlined,
        'type': 'layanan',
      },
    ],
    'Keluhan Sosial': [
      {
        'label': 'Pihak yang Terlibat',
        'icon': Icons.group_outlined,
        'type': 'umum',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _updateDynamicControllers();
  }

  void _updateDynamicControllers() {
    setState(() {
      _dynamicControllers.clear();
      final fields = kategoriFields[_kategori] ?? [];
      for (var i = 0; i < fields.length; i++) {
        _dynamicControllers['field_$i'] = TextEditingController();
      }
    });
  }

  Future<void> _pickImages() async {
    if (_files.length >= 5) {
      _showSnackBar("Maksimal 5 foto", Colors.orange);
      return;
    }

    try {
      final picked = await _picker.pickMultiImage(imageQuality: 70);

      for (var item in picked) {
        final file = File(item.path);
        final ext = item.path.split('.').last.toLowerCase();

        if (!_allowedExtensions.contains(ext)) {
          _showSnackBar(
            "Format $ext tidak didukung. Gunakan JPG/PNG.",
            Colors.red,
          );
          continue;
        }

        if (file.lengthSync() > _maxFileSize) {
          _showSnackBar(
            "Foto ${item.name} terlalu besar (Maks 5MB)",
            Colors.red,
          );
          continue;
        }

        if (_files.length < 5) {
          setState(() => _files.add(file));
        }
      }
    } catch (e) {
      _showSnackBar("Gagal mengambil foto", Colors.red);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_files.isEmpty) {
      _showSnackBar("Mohon unggah minimal 1 foto bukti", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyAuthToken);

      var uri = Uri.parse('${AppConstants.baseUrl}/complaints');
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['title'] = _judul.text;
      request.fields['category'] = _kategori;
      request.fields['message'] = _deskripsi.text;
      request.fields['lokasi'] = _lokasi.text;

      _dynamicControllers.forEach((key, controller) {
        final fields = kategoriFields[_kategori]!;
        final index = int.parse(key.replaceFirst('field_', ''));
        final apiKey = fields[index]['label']
            .toString()
            .toLowerCase()
            .replaceAll(' ', '_');

        if (controller.text.isNotEmpty) {
          request.fields[apiKey] = controller.text;
        }
      });

      if (_files.isNotEmpty) {
        for (var file in _files) {
          request.files.add(
            await http.MultipartFile.fromPath('attachment_path', file.path),
          );
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          _showSnackBar("Pengaduan berhasil dikirim secara aman!", accentGreen);
          _resetForm();
        }
      } else {
        _showSnackBar(
          "Gagal: ${responseData['message'] ?? 'Terjadi kesalahan'}",
          Colors.red,
        );
      }
    } catch (e) {
      debugPrint("Error Submit: $e");
      _showSnackBar("Koneksi gagal ke ${AppConstants.baseUrl}", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _judul.clear();
    _lokasi.clear();
    _deskripsi.clear();
    setState(() => _files.clear());
    _updateDynamicControllers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGray,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.report_problem, color: primaryBlue, size: 24),
            SizedBox(width: 8),
            const Text(
              "Ajukan Pengaduan",
              style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: primaryBlue,
        elevation: 2,
        shadowColor: primaryBlue.withOpacity(0.1),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Header dengan Gradient
              _buildHeaderSection(),

              const SizedBox(height: 20),

              // 1. Pilih Kategori
              _buildSectionTitle("Kategori Pengaduan", Icons.category_outlined),
              const SizedBox(height: 12),
              _buildCategoryCard(),

              const SizedBox(height: 20),

              // 2. Info Utama
              _buildSectionTitle("Informasi Utama", Icons.info_outline),
              const SizedBox(height: 12),
              _buildInfoCard(),

              // 3. Dynamic Fields
              if (_dynamicControllers.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildSectionTitle("Detail Khusus", Icons.assignment_outlined),
                const SizedBox(height: 12),
                _buildDynamicCard(),
              ],

              // 4. Bukti Foto
              const SizedBox(height: 20),
              _buildSectionTitle("Bukti Foto", Icons.camera_alt_outlined),
              const SizedBox(height: 12),
              _buildPhotoCard(),

              const SizedBox(height: 20),

              // WhatsApp Info
              const WhatsAppInfo(),

              const SizedBox(height: 24),

              // Submit Button
              _buildSubmitButton(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ WIDGET BUILDERS

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryBlue, lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.report_problem,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Form Pengaduan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Bantu kami membangun desa lebih baik",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryBlue, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _kategori,
        decoration: InputDecoration(
          filled: true,
          fillColor: bgGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryBlue, width: 2),
          ),
        ),
        icon: const Icon(Icons.arrow_drop_down, color: primaryBlue),
        items: kategoriFields.keys
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
        onChanged: (val) {
          setState(() => _kategori = val!);
          _updateDynamicControllers();
        },
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInput("Judul Laporan", _judul, Icons.title),
          const SizedBox(height: 16),
          _buildInput("Lokasi Kejadian", _lokasi, Icons.location_on_outlined),
          const SizedBox(height: 16),
          _buildInput(
            "Deskripsi Lengkap",
            _deskripsi,
            Icons.description_outlined,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: _buildDynamicInputs()),
    );
  }

  Widget _buildPhotoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: [_buildPhotoPreview()]),
    );
  }

  List<Widget> _buildDynamicInputs() {
    final fields = kategoriFields[_kategori] ?? [];
    return List.generate(fields.length, (i) {
      return Padding(
        padding: EdgeInsets.only(bottom: i < fields.length - 1 ? 16 : 0),
        child: _buildInput(
          fields[i]['label'],
          _dynamicControllers['field_$i']!,
          fields[i]['icon'],
        ),
      );
    });
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? "$label wajib diisi" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textGray),
        prefixIcon: Icon(icon, size: 20, color: primaryBlue),
        filled: true,
        fillColor: bgGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info text
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accentGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accentGold.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: accentGold, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Unggah maksimal 5 foto (JPG/PNG, maks 5MB)",
                  style: TextStyle(color: textDark, fontSize: 13),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Photo preview
        if (_files.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _files.length,
              itemBuilder: (context, i) => Stack(
                children: [
                  Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryBlue.withOpacity(0.3)),
                      image: DecorationImage(
                        image: FileImage(_files[i]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 15,
                    child: GestureDetector(
                      onTap: () => setState(() => _files.removeAt(i)),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (_files.isNotEmpty) const SizedBox(height: 16),

        // Upload button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _files.length >= 5 ? null : _pickImages,
            icon: Icon(
              Icons.add_a_photo_outlined,
              color: _files.length >= 5 ? textGray : primaryBlue,
            ),
            label: Text(
              _files.isEmpty
                  ? "Ambil Foto Bukti"
                  : "Tambah Foto (${_files.length}/5)",
              style: TextStyle(
                color: _files.length >= 5 ? textGray : primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: _files.length >= 5 ? textGray : primaryBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue, // ✅ Solid color, tanpa gradient
          foregroundColor: Colors.white,
          elevation: 3, // ✅ Shadow lebih halus
          shadowColor: primaryBlue.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "KIRIM PENGADUAN",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _judul.dispose();
    _lokasi.dispose();
    _deskripsi.dispose();
    _dynamicControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}
