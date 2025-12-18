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

  // --- DROPDOWN VARIABLES ---
  String? _selectedJenisKelamin;
  String? _selectedStatusKawin;
  String? _selectedGolDarah;
  String? _selectedKewarganegaraan;
  String? _selectedPekerjaan; // [BARU] Mengganti controller pekerjaan

  // --- LIST PILIHAN ---
  final List<String> _listJK = ['Laki-laki', 'Perempuan'];
  final List<String> _listStatus = ['Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati'];
  final List<String> _listGolDarah = ['A', 'B', 'AB', 'O', '-'];
  final List<String> _listWargaNegara = ['WNI', 'WNA'];
  
  // [BARU] Daftar Pekerjaan Tetap
  final List<String> _pekerjaanList = [
    'PNS / TNI / POLRI',
    'Karyawan Swasta',
    'Wiraswasta',
    'Buruh Harian Lepas',
    'Pelajar / Mahasiswa',
    'Ibu Rumah Tangga',
    'Tidak / Belum Bekerja',
    'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    final w = widget.warga;

    _namaController = TextEditingController(text: w['nama_lengkap']);
    _nikController = TextEditingController(text: w['nik']);
    _kkController = TextEditingController(text: w['no_kk']);
    _alamatController = TextEditingController(text: w['alamat_lengkap'] ?? w['alamat'] ?? '');
    _tempatLahirController = TextEditingController(text: w['tempat_lahir']);
    _agamaController = TextEditingController(text: w['agama']);
    
    String tgl = w['tanggal_lahir'] ?? "";
    if (tgl.length > 10) tgl = tgl.substring(0, 10); 
    _tanggalLahirController = TextEditingController(text: tgl);

    // Inisialisasi Dropdown
    _selectedJenisKelamin = _validateDropdown(w['jenis_kelamin'], _listJK);
    _selectedStatusKawin = _validateDropdown(w['status_perkawinan'], _listStatus);
    _selectedGolDarah = _validateDropdown(w['golongan_darah'], _listGolDarah);
    _selectedKewarganegaraan = _validateDropdown(w['kewarganegaraan'], _listWargaNegara);
    _selectedPekerjaan = _validateDropdown(w['pekerjaan'], _pekerjaanList); // [BARU]
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
      "alamat": _alamatController.text, // Key 'alamat' sesuai backend
      "tempat_lahir": _tempatLahirController.text,
      "tanggal_lahir": _tanggalLahirController.text,
      "jenis_kelamin": _selectedJenisKelamin,
      "agama": _agamaController.text,
      "pekerjaan": _selectedPekerjaan, // Diambil dari pilihan dropdown
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

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Jenis Kelamin"),
                      _buildDropdown(_selectedJenisKelamin, _listJK, (val) => setState(() => _selectedJenisKelamin = val)),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Gol. Darah"),
                      _buildDropdown(_selectedGolDarah, _listGolDarah, (val) => setState(() => _selectedGolDarah = val)),
                    ],
                  ),
                ),
              ],
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
            _buildDropdown(_selectedPekerjaan, _pekerjaanList, (val) => setState(() => _selectedPekerjaan = val)),
            const SizedBox(height: 15),

            _buildLabel("Status Perkawinan"),
            _buildDropdown(_selectedStatusKawin, _listStatus, (val) => setState(() => _selectedStatusKawin = val)),
            const SizedBox(height: 15),

            _buildLabel("Kewarganegaraan"),
            _buildDropdown(_selectedKewarganegaraan, _listWargaNegara, (val) => setState(() => _selectedKewarganegaraan = val)),

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

  // --- HELPER WIDGETS ---
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

  Widget _buildDropdown(String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
      onChanged: onChanged,
      decoration: _inputDecor("Pilih Opsi"),
      validator: (val) => val == null ? "Wajib dipilih" : null,
    );
  }
}