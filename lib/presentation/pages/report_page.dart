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

  // ✅ Dynamic controllers untuk field kategori
  final Map<String, TextEditingController> _dynamicControllers = {};

  // ✅ UBAH: Support multiple files (max 5)
  final List<File> _files = [];
  final _picker = ImagePicker();

  // ✅ Konstanta validasi file
  static const int _maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const int _maxFileCount = 5;
  static const List<String> _allowedExtensions = [
    'jpg', 'jpeg', 'png', 'gif', // Foto
    'mp4', 'avi', 'mov', 'mkv', 'webm', // Video
  ];

  static final Map<String, RegExp> _regexPatterns = {
    // Judul: alphanumeric, spasi, dan tanda baca umum (3-200 karakter)
    'judul': RegExp(r"^[\w\s#\/\\\-.,;:]{5,250}$"),

    // Lokasi: alphanumeric, spasi, #, /, \, -, ., , (5-250 karakter)
    'lokasi': RegExp(r"^[\w\s#\/\\\-.,;:]{5,250}$"),

    // Deskripsi: semua karakter termasuk newline (10-1000 karakter)
    'deskripsi': RegExp(r"^[\s\S]{10,1000}$"),

    // Nama: huruf, spasi, titik, apostrof (2-100 karakter)
    'nama': RegExp(r"^[a-zA-Z\s'.]{2,100}$"),

    // Layanan: mirip lokasi (2-150 karakter)
    'layanan': RegExp(r"^[\w\s#\/\\\-.,;:]{2,150}$"),

    // Umum: default pattern (2-200 karakter)
    'umum': RegExp(r"^[\w\s#\/\\\-.,;:]{2,250}$"),
  };

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
    'Pelanggaran HAM': [
      {
        'label': 'Jenis Pelanggaran',
        'icon': Icons.gavel_outlined,
        'type': 'umum',
      },
      {
        'label': 'Pelaku / Terlapor',
        'icon': Icons.person_search_outlined,
        'type': 'nama',
      },
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

  void _updateDynamicControllers() {
    for (var controller in _dynamicControllers.values) {
      controller.dispose();
    }
    _dynamicControllers.clear();

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

  // ✅ VALIDASI: Cek ekstensi file
  bool _isValidExtension(String path) {
    final ext = path.split('.').last.toLowerCase();
    return _allowedExtensions.contains(ext);
  }

  // ✅ VALIDASI: Cek ukuran file
  bool _isValidFileSize(File file) {
    return file.lengthSync() <= _maxFileSize;
  }

  // ✅ VALIDASI: Format pesan error ukuran file
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  // ✅ PICK FILE: Support foto & video, multi pick dengan validasi
  Future<void> _pickFiles() async {
    // ✅ Cek limit file
    if (_files.length >= _maxFileCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Maksimal $_maxFileCount file boleh diunggah"),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      // ✅ Pick multiple media (image & video)
      final picked = await _picker.pickMultiImage(
        imageQuality: 70,
        limit: _maxFileCount - _files.length,
      );

      // ✅ Tambahkan juga opsi pick video (jika perlu)
      // Note: pickMultiImage hanya untuk gambar. Untuk video, gunakan pickVideo terpisah
      // Jika ingin support video, tambahkan logika berikut:
      /*
      final pickedVideo = await _picker.pickVideo(source: ImageSource.gallery);
      if (pickedVideo != null) {
        // validasi video...
      }
      */

      for (var item in picked) {
        final file = File(item.path);

        // ✅ Validasi ekstensi
        if (!_isValidExtension(item.path)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Format file tidak didukung: ${item.path.split('.').last}",
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          continue;
        }

        // ✅ Validasi ukuran
        if (!_isValidFileSize(file)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Ukuran file terlalu besar: ${_formatFileSize(file.lengthSync())} (maks 10MB)",
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          continue;
        }

        // ✅ Tambahkan ke list jika lolos validasi
        if (_files.length < _maxFileCount) {
          setState(() => _files.add(file));
        }
      }

      // ✅ Feedback jika berhasil
      if (picked.isNotEmpty && _files.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${picked.length} file berhasil ditambahkan"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memilih file: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ✅ Hapus file dari list
  void _removeFile(int index) {
    setState(() => _files.removeAt(index));
  }

  // ✅ VALIDASI FORM: Regex + required
  String? _validateWithRegex(String? value, String label, String patternKey) {
    if (value == null || value.trim().isEmpty) {
      return '$label wajib diisi';
    }
    final pattern = _regexPatterns[patternKey] ?? _regexPatterns['umum']!;
    if (!pattern.hasMatch(value.trim())) {
      return 'Format $label tidak valid';
    }
    return null;
  }

  void _submit() async {
    // ✅ Validasi form teks
    if (!_formKey.currentState!.validate()) return;

    // ✅ Validasi file: minimal 1 file
    if (_files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Minimal 1 bukti foto/video harus diunggah"),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulasi proses submit
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
      // Reset form
      _formKey.currentState?.reset();
      setState(() {
        _files.clear();
        // _image = null; // jika masih ada referensi lama
      });
      _updateDynamicControllers();
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4F46E5);
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
        automaticallyImplyLeading: false,
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
                  _inputRegex(
                    'Judul Laporan',
                    _judul,
                    Icons.title,
                    primaryColor,
                    'judul',
                  ),
                  _inputRegex(
                    'Lokasi Kejadian',
                    _lokasi,
                    Icons.location_on_outlined,
                    primaryColor,
                    'lokasi',
                  ),
                  _inputRegex(
                    'Deskripsi',
                    _deskripsi,
                    Icons.description_outlined,
                    primaryColor,
                    'deskripsi',
                    maxLines: 4,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Dynamic Fields Card
              if (kategoriFields[_kategori]!.isNotEmpty)
                _buildSectionCard(
                  title: "Detail Tambahan",
                  icon: Icons.list_alt,
                  children: _buildDynamicFields(primaryColor),
                ),

              const SizedBox(height: 20),

              // Upload Bukti Card
              _buildSectionCard(
                title: "Bukti Foto/Video",
                icon: Icons.image_outlined,
                children: [_buildFilePicker()],
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

  // ... [Widget helper lainnya tetap sama, hanya _input diganti _inputRegex] ...

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
          _updateDynamicControllers();
        });
      },
      validator: (value) => value == null ? 'Kategori wajib dipilih' : null,
    );
  }

  List<Widget> _buildDynamicFields(Color primaryColor) {
    final fields = kategoriFields[_kategori] ?? [];
    return List.generate(fields.length, (index) {
      final controller =
          _dynamicControllers['field_$index'] ?? TextEditingController();
      final fieldType = fields[index]['type'] ?? 'umum';
      return _inputRegex(
        fields[index]['label'],
        controller,
        fields[index]['icon'],
        primaryColor,
        fieldType,
      );
    });
  }

  // ✅ INPUT dengan Regex Validation
  Widget _inputRegex(
    String label,
    TextEditingController controller,
    IconData icon,
    Color primaryColor,
    String patternKey, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) => _validateWithRegex(value, label, patternKey),
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

  // ✅ FILE PICKER dengan preview multiple & remove
  Widget _buildFilePicker() {
    return Column(
      children: [
        // Preview files
        if (_files.isNotEmpty) ...[
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _files.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(_files[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeFile(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    // Indikator tipe file
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _files[index].path.split('.').last.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Info counter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${_files.length} / $_maxFileCount file",
              style: TextStyle(
                color: _files.length >= _maxFileCount
                    ? Colors.red
                    : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              "Maks 10MB/file",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Pick button
        OutlinedButton.icon(
          onPressed: _files.length >= _maxFileCount ? null : _pickFiles,
          icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
          label: Text(_files.isEmpty ? "Pilih Foto/Video" : "Tambah File"),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: Color(0xFF4F46E5)),
            foregroundColor: const Color(0xFF4F46E5),
          ),
        ),

        // Helper text
        if (_files.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Format: JPG, PNG, MP4, dll • Maksimal 5 file • Maksimal 10MB per file",
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
              textAlign: TextAlign.center,
            ),
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
