import 'dart:async';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:simpedesa/data/models/complaint_model.dart';
import '../../widgets/report/whatsapp_info.dart';
import 'package:simpedesa/core/constants.dart';
import 'package:simpedesa/data/services/complaint_service.dart';

class ComplaintPage extends StatefulWidget {
  final ComplaintModel? complaint;

  const ComplaintPage({super.key, this.complaint});

  bool get isEdit => complaint != null;
  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  bool get isEdit => widget.isEdit;
  // Controllers
  final _judul = TextEditingController();
  final _lokasi = TextEditingController();
  final _deskripsi = TextEditingController();
  final _nomorTelepon = TextEditingController();
  final Map<String, TextEditingController> _dynamicControllers = {};
  final List<String> _existingImages = [];

  String _kategori = 'Fasilitas';
  bool _isLoading = false;
  final List<File> _files = [];
  final _picker = ImagePicker();

  // ✅ WARNA TEMA SimpeDesa (Sesuai Logo)
  static const Color primaryBlue = Color(0xFF243E8F);
  static const Color lightBlue = Color(0xFF4A90E2);
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

    if (isEdit) {
      _judul.text = widget.complaint!.title;
      _kategori = widget.complaint!.category!;
      _lokasi.text = widget.complaint!.getDecryptedValue("lokasi");
      _deskripsi.text = widget.complaint!.getDecryptedValue("deskripsi");
      _nomorTelepon.text = widget.complaint!.getDecryptedValue("nomor_telepon");
      final bukti = widget.complaint!.getDecryptedValue(
        "bukti_pendukung",
        fallback: "",
      );

      if (bukti.isNotEmpty) {
        _existingImages.addAll(
          bukti.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
        );
      }
    }

    _updateDynamicControllers();

    if (isEdit) {
      final data = widget.complaint!.decryptedContent;
      final fields = kategoriFields[_kategori] ?? [];

      for (int i = 0; i < fields.length; i++) {
        final apiKey = fields[i]["label"].toString().toLowerCase().replaceAll(
          " ",
          "_",
        );

        _dynamicControllers["field_$i"]?.text = data[apiKey]?.toString() ?? "";
      }
    }
  }

  void _updateDynamicControllers() {
    _dynamicControllers.clear();

    final fields = kategoriFields[_kategori] ?? [];

    for (var i = 0; i < fields.length; i++) {
      _dynamicControllers['field_$i'] = TextEditingController();
    }
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

        if (_files.length >= 5) {
          break;
        }

        setState(() {
          _files.add(file);
        });
      }
    } catch (e) {
      _showSnackBar("Gagal mengambil foto", Colors.red);
    }
  }

  void _showSnackBar(String msg, Color color) {
    if (!mounted) return; // ✅ Cegah error jika halaman sudah keburu ditutup

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submit() async {
    debugPrint("=== MASUK KE SUBMIT ===");

    if (!_formKey.currentState!.validate()) {
      debugPrint("VALIDASI FORM GAGAL");
      return;
    }
    if (isEdit && !_hasChanges()) {
      _showSnackBar("Tidak ada perubahan yang disimpan.", Colors.orange);
      return;
    }

    debugPrint("FILES = ${_files.length}");
    debugPrint("EDIT = $isEdit");
    setState(() {});

    if (!isEdit && _files.isEmpty) {
      debugPrint("FOTO MASIH KOSONG");

      setState(() {});

      return;
    }

    if (!isEdit && _files.isEmpty) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      bool success;

      if (isEdit) {
        success = await _updateComplaint();
      } else {
        success = await _createComplaint();
      }

      if (!mounted) return;

      if (success) {
        Navigator.pop(context, true);
      } else {
        throw Exception("Operasi gagal");
      }
    } catch (e, s) {
      debugPrint(e.toString());

      debugPrint(s.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
            Text(
              isEdit ? "Edit Pengaduan" : "Ajukan Pengaduan",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
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
          setState(() {
            _kategori = val!;
            _updateDynamicControllers();
          });
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
          _buildInput(
            "Nomor Telepon yang Dapat Dihubungi",
            _nomorTelepon,
            Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(13),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Nomor telepon wajib diisi";
              }

              if (!RegExp(r'^08[0-9]{8,11}$').hasMatch(value)) {
                return "Nomor telepon harus berupa angka";
              }

              return null;
            },
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
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator:
          validator ??
          (v) => (v == null || v.trim().isEmpty) ? "$label wajib diisi" : null,
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
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Unggah maksimal 5 foto (JPG/PNG, maks 5MB)",
                  style: TextStyle(color: textDark, fontSize: 13),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ======================
        // Preview gambar lama
        // ======================
        // ======================
        // Preview gambar lama (Existing Images)
        // ======================
        if (_existingImages
            .isNotEmpty) // Hapus "&& _files.isEmpty" agar tidak bentrok
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _existingImages.length,
              itemBuilder: (context, i) => Stack(
                children: [
                  GestureDetector(
                    // Tambahkan aksi klik untuk melihat gambar
                    onTap: () => _showImageDialog(
                      "${AppConstants.baseImageUrl}${_existingImages[i]}",
                      false,
                    ),
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryBlue.withOpacity(0.3)),
                        image: DecorationImage(
                          image: NetworkImage(
                            "${AppConstants.baseImageUrl}${_existingImages[i]}",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    // Tombol "X" untuk gambar lama
                    top: 5,
                    right: 15,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _existingImages.removeAt(i);
                        });
                      },
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

        if (_existingImages.isNotEmpty) const SizedBox(height: 16),

        // ======================
        // Preview gambar baru (Files)
        // ======================
        if (_files.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _files.length,
              itemBuilder: (context, i) => Stack(
                children: [
                  GestureDetector(
                    // Tambahkan aksi klik untuk melihat gambar
                    onTap: () => _showImageDialog(_files[i], true),
                    child: Container(
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
                  ),
                  Positioned(
                    // Tombol "X" untuk gambar baru
                    top: 5,
                    right: 15,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _files.removeAt(i);
                        });
                      },
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

        if (_existingImages.isNotEmpty || _files.isNotEmpty)
          const SizedBox(height: 16),

        // Upload Button
        FormField<List<File>>(
          validator: (_) {
            if (!isEdit && _files.isEmpty) {
              return "Bukti foto wajib disertakan.";
            }

            if (isEdit && _files.isEmpty && _existingImages.isEmpty) {
              return "Bukti foto wajib disertakan.";
            }

            return null;
          },
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PERBAIKAN DI SINI
                SizedBox(
                  width: double
                      .infinity, // Hapus ini jika tombol tidak ingin sepanjang layar
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await _pickImages();
                      field.didChange(_files);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: field.hasError ? Colors.red : primaryBlue,
                        width: 1.5, // Ketebalan border
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Mengikuti radius awal
                      ),
                    ),
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: Text(
                      _files.isEmpty
                          ? "Ambil Foto Bukti"
                          : "Tambah Foto (${_files.length}/5)",
                    ),
                  ),
                ),

                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 12),
                    child: Text(
                      field.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submit,
        style: OutlinedButton.styleFrom(side: BorderSide.none),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isEdit ? "SIMPAN PERUBAHAN" : "KIRIM PENGADUAN",
                    style: const TextStyle(
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
    _nomorTelepon.dispose();
    super.dispose();
  }

  Future<bool> _createComplaint() async {
    final dynamicFields = _prepareDynamicFields();

    _printDebug(isEdit: false, dynamicFields: dynamicFields);

    return await ComplaintService().createComplaint(
      title: _judul.text.trim(),

      category: _kategori,

      message: _deskripsi.text.trim(),

      lokasi: _lokasi.text.trim(),

      dynamicFields: dynamicFields,

      attachments: _files,
    );
  }

  Future<bool> _updateComplaint() async {
    final dynamicFields = _prepareDynamicFields();

    _printDebug(isEdit: true, dynamicFields: dynamicFields);

    return await ComplaintService().updateComplaint(
      complaintId: widget.complaint!.id,
      title: _judul.text.trim(),
      category: _kategori,
      message: _deskripsi.text.trim(),
      lokasi: _lokasi.text.trim(),
      dynamicFields: dynamicFields,
      attachments: _files,
    );
  }

  Map<String, String> _prepareDynamicFields() {
    final Map<String, String> data = {};

    final fields = kategoriFields[_kategori] ?? [];

    _dynamicControllers.forEach((key, controller) {
      if (controller.text.trim().isEmpty) return;

      final index = int.parse(key.replaceFirst("field_", ""));

      final apiKey = fields[index]["label"].toString().toLowerCase().replaceAll(
        " ",
        "_",
      );

      data[apiKey] = controller.text.trim();
    });
    data["nomor_telepon"] = _nomorTelepon.text.trim();
    return data;
  }

  bool _hasChanges() {
    if (!isEdit) return true;

    final complaint = widget.complaint!;

    // Field utama
    if (_judul.text.trim() != complaint.title.trim()) {
      return true;
    }

    if (_kategori != complaint.category) {
      return true;
    }

    if (_lokasi.text.trim() !=
        complaint.getDecryptedValue("lokasi", fallback: "")) {
      return true;
    }

    if (_deskripsi.text.trim() !=
        complaint.getDecryptedValue("deskripsi", fallback: "")) {
      return true;
    }

    if (_nomorTelepon.text.trim() !=
        complaint.getDecryptedValue("nomor_telepon", fallback: "")) {
      return true;
    }

    // Field dinamis
    final fields = kategoriFields[_kategori] ?? [];

    for (int i = 0; i < fields.length; i++) {
      final apiKey = fields[i]["label"].toString().toLowerCase().replaceAll(
        " ",
        "_",
      );

      final oldValue = complaint.getDecryptedValue(apiKey, fallback: "");

      final newValue = _dynamicControllers["field_$i"]?.text.trim() ?? "";

      if (oldValue != newValue) {
        return true;
      }
    }

    // Ada foto baru
    if (_files.isNotEmpty) {
      return true;
    }

    // Ada foto lama yang dihapus
    final oldImages = complaint
        .getDecryptedValue("bukti_pendukung", fallback: "")
        .split(",")
        .where((e) => e.trim().isNotEmpty)
        .toList();

    if (oldImages.length != _existingImages.length) {
      return true;
    }

    return false;
  }

  void _printDebug({
    required bool isEdit,
    required Map<String, String> dynamicFields,
  }) {
    debugPrint("");
    debugPrint("========================================");
    debugPrint("MODE      : ${isEdit ? "EDIT" : "CREATE"}");
    debugPrint("TITLE     : ${_judul.text}");
    debugPrint("CATEGORY  : $_kategori");
    debugPrint("LOCATION  : ${_lokasi.text}");
    debugPrint("DESC      : ${_deskripsi.text}");
    debugPrint("FILES     : ${_files.length}");

    debugPrint("----------- Dynamic Field -----------");

    if (dynamicFields.isEmpty) {
      debugPrint("Tidak ada");
    } else {
      dynamicFields.forEach((k, v) {
        debugPrint("$k : $v");
      });
    }

    debugPrint("========================================");
  }

  void _showImageDialog(dynamic imageSource, bool isFile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              // Agar gambar bisa di-zoom
              child: isFile
                  ? Image.file(imageSource as File, fit: BoxFit.contain)
                  : Image.network(imageSource as String, fit: BoxFit.contain),
            ),
            Positioned(
              top: 10,
              right: 10,
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
}
