import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PengaduanPage extends StatefulWidget {
  const PengaduanPage({super.key});

  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  String _kategori = 'Fasilitas';

  final _judul = TextEditingController();
  final _lokasi = TextEditingController();
  final _deskripsi = TextEditingController();
  final _tambahan1 = TextEditingController();
  final _tambahan2 = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  final kategoriList = [
    'Fasilitas',
    'Kinerja Perangkat Desa',
    'Layanan Publik',
    'Keluhan Sosial',
    'Pelanggaran HAM',
  ];

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: source, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajukan Pengaduan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _dropdownKategori(),
            const SizedBox(height: 12),
            _input('Judul', _judul),
            _input('Lokasi', _lokasi),
            _input('Deskripsi', _deskripsi, maxLines: 4),

            if (_kategori == 'Kinerja Perangkat Desa')
              _input('Nama Perangkat Desa', _tambahan1),

            if (_kategori == 'Layanan Publik')
              _input('Nama Layanan / Unit', _tambahan1),

            if (_kategori == 'Keluhan Sosial')
              _input('Pihak yang Terlibat', _tambahan1),

            if (_kategori == 'Pelanggaran HAM') ...[
              _input('Jenis Pelanggaran', _tambahan1),
              _input('Pelaku / Terlapor', _tambahan2),
            ],

            const SizedBox(height: 16),

            // 🔹 UPLOAD IMAGE
            const Text(
              'Bukti Pendukung (Foto)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.image),
                  label: const Text('Galeri'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _image!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 20),

            // 🔹 SUBMIT
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send),
              label: const Text('Kirim Pengaduan'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdownKategori() {
    return DropdownButtonFormField<String>(
      value: _kategori,
      items: kategoriList
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (val) => setState(() => _kategori = val!),
      decoration: const InputDecoration(
        labelText: 'Kategori Pengaduan',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _submit() {
    if (_judul.text.isEmpty || _deskripsi.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi data pengaduan')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaduan berhasil dikirim')),
    );
  }
}
