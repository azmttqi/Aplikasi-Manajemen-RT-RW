import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EditWargaScreen extends StatefulWidget {
  final Map<String, dynamic> warga;

  const EditWargaScreen({super.key, required this.warga});

  @override
  State<EditWargaScreen> createState() => _EditWargaScreenState();
}

class _EditWargaScreenState extends State<EditWargaScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // --- CONTROLLERS ---
  late TextEditingController _namaController;
  late TextEditingController _nikController;
  late TextEditingController _kkController;
  late TextEditingController _alamatController;
  late TextEditingController _tempatLahirController;
  late TextEditingController _tanggalLahirController;
  late TextEditingController _agamaController;
  late TextEditingController _pekerjaanController;

  // --- DROPDOWN VARIABLES ---
  String? _selectedJenisKelamin;
  String? _selectedStatusKawin;
  String? _selectedGolDarah;
  String? _selectedKewarganegaraan;

  final List<String> _listJK = ['Laki-laki', 'Perempuan'];
  final List<String> _listStatus = ['Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati'];
  final List<String> _listGolDarah = ['A', 'B', 'AB', 'O', '-'];
  final List<String> _listWargaNegara = ['WNI', 'WNA'];

  @override
  void initState() {
    super.initState();
    final w = widget.warga;

    _namaController = TextEditingController(text: w['nama_lengkap']);
    _nikController = TextEditingController(text: w['nik']);
    _kkController = TextEditingController(text: w['no_kk']);
    _alamatController = TextEditingController(text: w['alamat_lengkap'] ?? w['alamat'] ?? '');
    _tempatLahirController = TextEditingController(text: w['tempat_lahir']);
    
    String tgl = w['tanggal_lahir'] ?? "";
    if (tgl.length > 10) tgl = tgl.substring(0, 10); 
    _tanggalLahirController = TextEditingController(text: tgl);

    _agamaController = TextEditingController(text: w['agama']);
    _pekerjaanController = TextEditingController(text: w['pekerjaan']);

    _selectedJenisKelamin = _validateDropdown(w['jenis_kelamin'], _listJK);
    _selectedStatusKawin = _validateDropdown(w['status_perkawinan'], _listStatus);
    _selectedGolDarah = _validateDropdown(w['golongan_darah'], _listGolDarah);
    _selectedKewarganegaraan = _validateDropdown(w['kewarganegaraan'], _listWargaNegara);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _kkController.dispose();
    _alamatController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _agamaController.dispose();
    _pekerjaanController.dispose();
    super.dispose();
  }

  String? _validateDropdown(String? value, List<String> list) {
    if (value == null || value.isEmpty) return null;
    try {
      return list.firstWhere((e) => e.toLowerCase() == value.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      String formatted = "${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}";
      setState(() {
        _tanggalLahirController.text = formatted;
      });
    }
  }

  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final rawId = widget.warga['id'] ?? widget.warga['id_warga'];
    final int idWarga = int.tryParse(rawId.toString()) ?? 0;

    Map<String, dynamic> dataUpdate = {
      "nama_lengkap": _namaController.text,
      "nik": _nikController.text,
      "no_kk": _kkController.text,
      "alamat": _alamatController.text,
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
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data warga berhasil diperbarui! ✅"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memperbarui data ❌"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color themeBg = Color(0xFFFFF8E1);

    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        title: const Text("Edit Biodata Warga", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: themeBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "Perbarui informasi kependudukan warga di bawah ini.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            _buildLabel("Nama Lengkap"),
            TextFormField(
              controller: _namaController,
              decoration: _inputDecor("Masukkan Nama Lengkap"),
              validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("NIK"),
                      TextFormField(
                        controller: _nikController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecor("NIK"),
                        validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("No. KK"),
                      TextFormField(
                        controller: _kkController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecor("No. KK"),
                        validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            _buildLabel("Alamat Lengkap"),
            TextFormField(
              controller: _alamatController,
              maxLines: 3,
              decoration: _inputDecor("Jalan, No. Rumah, RT/RW..."),
              validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
            ),
            const SizedBox(height: 25),

            const Divider(),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Tempat Lahir"),
                      TextFormField(
                        controller: _tempatLahirController,
                        decoration: _inputDecor("Bandung"),
                        validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Tanggal Lahir"),
                      TextFormField(
                        controller: _tanggalLahirController,
                        readOnly: true,
                        decoration: _inputDecor("YYYY-MM-DD").copyWith(
                          suffixIcon: const Icon(Icons.calendar_today, size: 18),
                        ),
                        onTap: _pickDate,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            _buildLabel("Jenis Kelamin"),
            DropdownButtonFormField<String>(
              value: _selectedJenisKelamin,
              items: _listJK.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _selectedJenisKelamin = val),
              decoration: _inputDecor("Pilih Jenis Kelamin"),
              validator: (val) => val == null ? "Wajib dipilih" : null,
            ),
            const SizedBox(height: 15),

            _buildLabel("Agama"),
            TextFormField(
              controller: _agamaController,
              decoration: _inputDecor("Agama"),
              validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
            ),
            const SizedBox(height: 15),

            _buildLabel("Pekerjaan"),
            TextFormField(
              controller: _pekerjaanController,
              decoration: _inputDecor("Pekerjaan"),
              validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
            ),
            const SizedBox(height: 15),

            _buildLabel("Status Perkawinan"),
            DropdownButtonFormField<String>(
              value: _selectedStatusKawin,
              items: _listStatus.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _selectedStatusKawin = val),
              decoration: _inputDecor("Pilih Status"),
            ),
            const SizedBox(height: 15),

            _buildLabel("Kewarganegaraan"),
            DropdownButtonFormField<String>(
              value: _selectedKewarganegaraan,
              items: _listWargaNegara.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _selectedKewarganegaraan = val),
              decoration: _inputDecor("Pilih Kewarganegaraan"),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _simpanData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("SIMPAN PERUBAHAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }
}