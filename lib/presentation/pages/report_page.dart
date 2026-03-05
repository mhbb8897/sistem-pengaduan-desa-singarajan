import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();

  String _kategori = 'Fasilitas';
  bool _isLoading = false;

  final _judul = TextEditingController();
  final _lokasi = TextEditingController();
  final _deskripsi = TextEditingController();

  // Perbaikan: Menggunakan Map untuk dynamic controllers agar scalable
  final Map<String, TextEditingController> _dynamicControllers = {};

  File? _image;
  final _picker = ImagePicker();

  final Map<String, List<Map<String, dynamic>>> kategoriFields = {
    'Fasilitas': [],
    'Kinerja Perangkat Desa': [
      {'label': 'Nama Perangkat Desa', 'icon': Icons.person_outline},
    ],
    'Layanan Publik': [
      {'label': 'Nama Layanan / Unit', 'icon': Icons.account_balance_outlined},
    ],
    'Keluhan Sosial': [
      {'label': 'Pihak yang Terlibat', 'icon': Icons.group_outlined},
    ],
    'Pelanggaran HAM': [
      {'label': 'Jenis Pelanggaran', 'icon': Icons.gavel_outlined},
      {'label': 'Pelaku / Terlapor', 'icon': Icons.person_search_outlined},
    ],
  };

  @override
  void dispose() {
    _judul.dispose();
    _lokasi.dispose();
    _deskripsi.dispose();
    for (var controller in _dynamicControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Update controllers saat kategori berubah
  void _updateDynamicControllers() {
    // Dispose controller lama
    for (var controller in _dynamicControllers.values) {
      controller.dispose();
    }
    _dynamicControllers.clear();

    // Buat controller baru sesuai field kategori
    final fields = kategoriFields[_kategori] ?? [];
    for (var i = 0; i < fields.length; i++) {
      _dynamicControllers['field_$i'] = TextEditingController();
    }
  }

  @override
  void initState() {
    super.initState();
    _updateDynamicControllers();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulasi proses
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Pengaduan berhasil dikirim"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      // Reset form jika perlu
      _formKey.currentState?.reset();
      setState(() => _image = null);
      _updateDynamicControllers();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Warna Tema
    const primaryColor = Color(0xFF4F46E5); // Indigo
    const backgroundColor = Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 17, 73, 185),
      appBar: AppBar(
        title: const Text(
          "Ajukan Pengaduan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
        automaticallyImplyLeading: false, // ✅ Tambahkan baris ini
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Formulir Pengaduan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Silakan isi detail laporan Anda di bawah ini.",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    _buildDropdown(),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Info Utama Card
              _buildSectionCard(
                title: "Informasi Utama",
                icon: Icons.info_outline,
                children: [
                  _input('Judul Laporan', _judul, Icons.title, primaryColor),
                  _input(
                    'Lokasi Kejadian',
                    _lokasi,
                    Icons.location_on_outlined,
                    primaryColor,
                  ),
                  _input(
                    'Deskripsi',
                    _deskripsi,
                    Icons.description_outlined,
                    primaryColor,
                    maxLines: 4,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Dynamic Fields Card (Jika ada)
              if (kategoriFields[_kategori]!.isNotEmpty)
                _buildSectionCard(
                  title: "Detail Tambahan",
                  icon: Icons.list_alt,
                  children: _buildDynamicFields(primaryColor),
                ),

              const SizedBox(height: 20),

              // Upload Bukti Card
              _buildSectionCard(
                title: "Bukti Foto",
                icon: Icons.image_outlined,
                children: [_buildImagePicker()],
              ),

              const SizedBox(height: 30),

              // Submit Button
              _buildSubmitButton(primaryColor),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF4F46E5), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _kategori,
      decoration: InputDecoration(
        labelText: "Kategori Pengaduan",
        filled: true,
        fillColor: Colors.grey[50],
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
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
        ),
      ),
      items: kategoriFields.keys
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (val) {
        setState(() {
          _kategori = val!;
          _updateDynamicControllers(); // Reset controllers saat kategori berubah
        });
      },
    );
  }

  List<Widget> _buildDynamicFields(Color primaryColor) {
    final fields = kategoriFields[_kategori] ?? [];
    return List.generate(fields.length, (index) {
      final controller =
          _dynamicControllers['field_$index'] ?? TextEditingController();
      return _input(
        fields[index]['label'],
        controller,
        fields[index]['icon'],
        primaryColor,
      );
    });
  }

  Widget _input(
    String label,
    TextEditingController controller,
    IconData icon,
    Color primaryColor, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) =>
            value == null || value.isEmpty ? '$label wajib diisi' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[50],
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
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        if (_image != null)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: FileImage(_image!),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ), // ✅ backgroundBlendMode dihapus
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                    onPressed: () => setState(() => _image = null),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 40,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  "Belum ada foto dipilih",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text("Kamera"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF4F46E5)),
                  foregroundColor: const Color(0xFF4F46E5),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.image, size: 18),
                label: const Text("Galeri"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF4F46E5)),
                  foregroundColor: const Color(0xFF4F46E5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton(Color primaryColor) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Kirim Pengaduan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
