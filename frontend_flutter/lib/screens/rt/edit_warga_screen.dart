import 'package:flutter/material.dart';
import '../../services/api_service.dart';
// import 'package:intl/intl.dart'; // Pastikan tambah ini di pubspec.yaml jika belum (intl: ^0.18.0)
// Kalau error intl, hapus import ini dan pakai string biasa dulu, tapi sebaiknya install intl.

class EditWargaScreen extends StatefulWidget {
  final Map<String, dynamic> warga;

  const EditWargaScreen({super.key, required this.warga});

  @override
  State<EditWargaScreen> createState() => _EditWargaScreenState();
}

class _EditWargaScreenState extends State<EditWargaScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // --- CONTROLLERS (Input Teks) ---
  late TextEditingController _namaController;
  late TextEditingController _nikController;
  late TextEditingController _kkController;
  late TextEditingController _tempatLahirController;
  late TextEditingController _tanggalLahirController;
  late TextEditingController _agamaController;
  late TextEditingController _pekerjaanController;

  // --- DROPDOWN VARIABLES (Pilihan) ---
  String? _selectedJenisKelamin;
  String? _selectedStatusKawin;
  String? _selectedGolDarah;
  String? _selectedKewarganegaraan;

  // List Pilihan Dropdown
  final List<String> _listJK = ['Laki-laki', 'Perempuan'];
  final List<String> _listStatus = ['Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati'];
  final List<String> _listGolDarah = ['A', 'B', 'AB', 'O', '-'];
  final List<String> _listWargaNegara = ['WNI', 'WNA'];

  @override
  void initState() {
    super.initState();
    final w = widget.warga;

    // 1. Isi Controller Text
    _namaController = TextEditingController(text: w['nama_lengkap']);
    _nikController = TextEditingController(text: w['nik']);
    _kkController = TextEditingController(text: w['no_kk']);
    _tempatLahirController = TextEditingController(text: w['tempat_lahir']);
    
    // Format tanggal biar rapi (yyyy-MM-dd)
    String tgl = w['tanggal_lahir'] ?? "";
    if (tgl.length > 10) tgl = tgl.substring(0, 10); // Ambil 10 karakter pertama
    _tanggalLahirController = TextEditingController(text: tgl);

    _agamaController = TextEditingController(text: w['agama']);
    _pekerjaanController = TextEditingController(text: w['pekerjaan']);

    // 2. Isi Variabel Dropdown (Cek apakah data database cocok dengan list pilihan)
    _selectedJenisKelamin = _validateDropdown(w['jenis_kelamin'], _listJK);
    _selectedStatusKawin = _validateDropdown(w['status_perkawinan'], _listStatus);
    _selectedGolDarah = _validateDropdown(w['golongan_darah'], _listGolDarah);
    _selectedKewarganegaraan = _validateDropdown(w['kewarganegaraan'], _listWargaNegara);
  }

  // Fungsi bantu cek dropdown biar gak error kalau datanya aneh
  String? _validateDropdown(String? value, List<String> list) {
    if (value == null || value.isEmpty) return null;
    if (list.contains(value)) return value;
    return null; // Kalau data di DB tidak ada di list, biarkan kosong
  }

  // Fungsi Pilih Tanggal
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      // Format manual YYYY-MM-DD
      String formatted = "${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}";
      setState(() {
        _tanggalLahirController.text = formatted;
      });
    }
  }

  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Ambil ID
    final rawId = widget.warga['id'] ?? widget.warga['id_warga'];
    final int idWarga = int.tryParse(rawId.toString()) ?? 0;

    // Siapkan Data Lengkap
    Map<String, dynamic> dataUpdate = {
      "nama_lengkap": _namaController.text,
      "nik": _nikController.text,
      "no_kk": _kkController.text,
      "tempat_lahir": _tempatLahirController.text,
      "tanggal_lahir": _tanggalLahirController.text,
      "jenis_kelamin": _selectedJenisKelamin,
      "agama": _agamaController.text,
      "pekerjaan": _pekerjaanController.text,
      "status_perkawinan": _selectedStatusKawin,
      "golongan_darah": _selectedGolDarah,
      "kewarganegaraan": _selectedKewarganegaraan,
    };

    bool success = await ApiService.editWarga(idWarga, dataUpdate);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context, true); // Sukses kembali
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data warga berhasil disimpan! ✅"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menyimpan data ❌"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Biodata Warga"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // === HEADER SECTION ===
            const Text("Data Kependudukan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
            const Divider(),
            
            _buildTextField("Nama Lengkap", _namaController),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildTextField("NIK", _nikController, isNumber: true)),
                const SizedBox(width: 15),
                Expanded(child: _buildTextField("No. KK", _kkController, isNumber: true)),
              ],
            ),

            const SizedBox(height: 25),
            
            // === DATA PRIBADI SECTION ===
            const Text("Data Pribadi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
            const Divider(),

            Row(
              children: [
                Expanded(child: _buildTextField("Tempat Lahir", _tempatLahirController)),
                const SizedBox(width: 15),
                // DATE PICKER FIELD
                Expanded(
                  child: TextFormField(
                    controller: _tanggalLahirController,
                    readOnly: true, // Gabisa diketik, harus dipklik
                    decoration: const InputDecoration(
                      labelText: "Tanggal Lahir",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today, size: 18),
                    ),
                    onTap: _pickDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            // JENIS KELAMIN & GOL DARAH
            Row(
              children: [
                Expanded(
                  child: _buildDropdown("Jenis Kelamin", _selectedJenisKelamin, _listJK, (val) => setState(() => _selectedJenisKelamin = val)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildDropdown("Gol. Darah", _selectedGolDarah, _listGolDarah, (val) => setState(() => _selectedGolDarah = val)),
                ),
              ],
            ),
            const SizedBox(height: 15),

            _buildTextField("Agama", _agamaController),
            const SizedBox(height: 15),
            _buildDropdown("Status Perkawinan", _selectedStatusKawin, _listStatus, (val) => setState(() => _selectedStatusKawin = val)),
            
            const SizedBox(height: 25),

            // === DATA LAINNYA SECTION ===
            const Text("Pekerjaan & Lainnya", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
            const Divider(),

            _buildTextField("Pekerjaan", _pekerjaanController),
            const SizedBox(height: 15),
            _buildDropdown("Kewarganegaraan", _selectedKewarganegaraan, _listWargaNegara, (val) => setState(() => _selectedKewarganegaraan = val)),

            const SizedBox(height: 40),

            // === TOMBOL SIMPAN ===
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _simpanData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("SIMPAN PERUBAHAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget TextField Helper biar codingan gak panjang
  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
      validator: (value) => value == null || value.isEmpty ? "$label wajib diisi" : null,
    );
  }

  // Widget Dropdown Helper
  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}