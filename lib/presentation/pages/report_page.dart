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
  final _field1 = TextEditingController();
  final _field2 = TextEditingController();

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

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Ajukan Pengaduan")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildDropdown(theme),
              const SizedBox(height: 16),

              _input('Judul Laporan', _judul, Icons.title),
              _input('Lokasi Kejadian', _lokasi, Icons.location_on_outlined),
              _input(
                'Deskripsi',
                _deskripsi,
                Icons.description_outlined,
                maxLines: 4,
              ),

              ..._buildDynamicFields(),

              const SizedBox(height: 20),
              _buildImagePicker(),
              const SizedBox(height: 30),

              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _kategori,
      decoration: const InputDecoration(
        labelText: "Kategori Pengaduan",
        border: OutlineInputBorder(),
      ),
      items: kategoriFields.keys
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (val) => setState(() => _kategori = val!),
    );
  }

  List<Widget> _buildDynamicFields() {
    final fields = kategoriFields[_kategori] ?? [];

    return List.generate(fields.length, (index) {
      final controller = index == 0 ? _field1 : _field2;
      return _input(fields[index]['label'], controller, fields[index]['icon']);
    });
  }

  Widget _input(
    String label,
    TextEditingController controller,
    IconData icon, {
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
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        if (_image != null) Image.file(_image!, height: 200, fit: BoxFit.cover),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text("Kamera"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.image),
                label: const Text("Galeri"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Kirim Pengaduan"),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pengaduan berhasil dikirim")),
      );
    }
  }
}
