import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LengkapiProfilScreen extends StatefulWidget {
  final String statusVerifikasi;

  const LengkapiProfilScreen({super.key, this.statusVerifikasi = "pending"});

  @override
  State<LengkapiProfilScreen> createState() => _LengkapiProfilScreenState();
}

class _LengkapiProfilScreenState extends State<LengkapiProfilScreen> {
  final String baseUrl = "http://localhost:5000/api";

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isLocked = false; 

  // --- CONTROLLER ---
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController(); 

  // --- VARIABLE DROPDOWN ---
  String? _selectedGender;
  String? _selectedAgama;
  String? _selectedStatusKawin;
  String? _selectedGolDarah;
  String? _selectedKewarganegaraan;
  String? _selectedPekerjaan; // [BARU] Mengganti controller teks

  // --- LIST DATA ---
  final List<String> _genderList = ["Laki-laki", "Perempuan"];
  final List<String> _agamaList = ["Islam", "Kristen", "Katolik", "Hindu", "Buddha", "Konghucu"];
  final List<String> _statusList = ["Belum Kawin", "Kawin", "Cerai Hidup", "Cerai Mati"];
  final List<String> _darahList = ["A", "B", "AB", "O", "-"];
  final List<String> _wniList = ["WNI", "WNA"];
  
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
    _checkLockStatus();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _alamatController.dispose(); 
    super.dispose();
  }

  void _checkLockStatus() {
    final status = widget.statusVerifikasi.toLowerCase().trim();
    if (status == 'verified' || status == 'disetujui' || status == '1') {
      setState(() {
        _isLocked = true;
      });
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _handleSessionExpired();
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/warga/pribadi/saya'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'] ?? jsonResponse;

        if (data != null) {
          setState(() {
            _nikController.text = data['nik'] ?? '';
            _namaController.text = data['nama_lengkap'] ?? '';
            _tempatLahirController.text = data['tempat_lahir'] ?? '';
            _alamatController.text = data['alamat_lengkap'] ?? data['alamat'] ?? ''; 

            if (data['tanggal_lahir'] != null) {
              String rawDate = data['tanggal_lahir'].toString();
              _tanggalLahirController.text = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;
            }

            // Validasi Dropdown
            _selectedGender = _validateDropdown(data['jenis_kelamin'], _genderList);
            _selectedAgama = _validateDropdown(data['agama'], _agamaList);
            _selectedStatusKawin = _validateDropdown(data['status_perkawinan'], _statusList);
            _selectedGolDarah = _validateDropdown(data['golongan_darah'], _darahList);
            _selectedKewarganegaraan = _validateDropdown(data['kewarganegaraan'], _wniList);
            _selectedPekerjaan = _validateDropdown(data['pekerjaan'], _pekerjaanList); // [BARU]
          });
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        _handleSessionExpired();
      }
    } catch (e) {
      print("Error Fetch Data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSessionExpired() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sesi berakhir, silakan login kembali"), backgroundColor: Colors.red),
    );
    Navigator.pop(context);
  }

  String? _validateDropdown(String? value, List<String> list) {
    if (value == null || value.isEmpty) return null;
    try {
      return list.firstWhere((element) => element.toLowerCase() == value.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _handleSessionExpired();
        return;
      }

      final dataKirim = {
        'nik': _nikController.text,
        'nama_lengkap': _namaController.text,
        'tempat_lahir': _tempatLahirController.text,
        'tanggal_lahir': _tanggalLahirController.text,
        'jenis_kelamin': _selectedGender,
        'agama': _selectedAgama,
        'pekerjaan': _selectedPekerjaan, // [UBAH] Mengirim dari variabel dropdown
        'alamat_lengkap': _alamatController.text, 
        'status_perkawinan': _selectedStatusKawin,
        'golongan_darah': _selectedGolDarah,
        'kewarganegaraan': _selectedKewarganegaraan,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/warga/update-data'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(dataKirim),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil disimpan! ✅"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception("Gagal simpan: ${response.body}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan data: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputColor = _isLocked ? Colors.grey.shade200 : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lengkapi Data Pribadi"),
        backgroundColor: const Color(0xFFFFF8E1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFFFF8E1),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLocked)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock, color: Colors.blue),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                "Data Anda sudah terverifikasi. Gunakan menu 'Ajukan Perubahan' jika ingin mengubah data.",
                                style: TextStyle(fontSize: 12, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Text(
                      "Mohon lengkapi data berikut untuk keperluan administrasi RT.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("Nama Lengkap"),
                    TextFormField(
                      controller: _namaController,
                      enabled: !_isLocked,
                      decoration: _inputDecor("Nama Lengkap", inputColor),
                      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 15),

                    _buildLabel("NIK"),
                    TextFormField(
                      controller: _nikController,
                      enabled: !_isLocked,
                      decoration: _inputDecor("Nomor Induk Kependudukan", inputColor),
                      keyboardType: TextInputType.number,
                      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 15),

                    _buildLabel("Tempat Lahir"),
                    TextFormField(
                      controller: _tempatLahirController,
                      enabled: !_isLocked,
                      decoration: _inputDecor("Contoh: Bandung", inputColor),
                      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 15),

                    _buildLabel("Tanggal Lahir"),
                    TextFormField(
                      controller: _tanggalLahirController,
                      enabled: !_isLocked,
                      readOnly: true,
                      decoration: _inputDecor("YYYY-MM-DD", inputColor).copyWith(
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      onTap: _isLocked ? null : () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _tanggalLahirController.text =
                                "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 15),

                    _buildLabel("Jenis Kelamin"),
                    _buildDropdown(_selectedGender, _genderList, (val) => setState(() => _selectedGender = val), inputColor),
                    const SizedBox(height: 15),

                    _buildLabel("Agama"),
                    _buildDropdown(_selectedAgama, _agamaList, (val) => setState(() => _selectedAgama = val), inputColor),
                    const SizedBox(height: 15),

                    // --- [BARU] DROPDOWN PEKERJAAN ---
                    _buildLabel("Pekerjaan"),
                    _buildDropdown(_selectedPekerjaan, _pekerjaanList, (val) => setState(() => _selectedPekerjaan = val), inputColor),
                    const SizedBox(height: 15),

                    _buildLabel("Alamat Lengkap"),
                    TextFormField(
                      controller: _alamatController,
                      enabled: !_isLocked,
                      maxLines: 3,
                      decoration: _inputDecor("Jalan, No. Rumah, RT/RW, Blok...", inputColor),
                      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 15),

                    _buildLabel("Status Perkawinan"),
                    _buildDropdown(_selectedStatusKawin, _statusList, (val) => setState(() => _selectedStatusKawin = val), inputColor),
                    const SizedBox(height: 15),

                    _buildLabel("Golongan Darah (Opsional)"),
                    _buildDropdown(_selectedGolDarah, _darahList, (val) => setState(() => _selectedGolDarah = val), inputColor),
                    const SizedBox(height: 15),

                    _buildLabel("Kewarganegaraan"),
                    _buildDropdown(_selectedKewarganegaraan, _wniList, (val) => setState(() => _selectedKewarganegaraan = val), inputColor),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _isLocked
                          ? ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Data terkunci. Silakan ajukan perubahan data jika diperlukan.")),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                              child: const Text(
                                "DATA TERVERIFIKASI (READ ONLY)",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _isLoading ? null : _submitData,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text(
                                "SIMPAN DATA",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  InputDecoration _inputDecor(String hint, Color fillColor) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: fillColor,
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }

  Widget _buildDropdown(String? value, List<String> items, Function(String?) onChanged, Color fillColor) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: _isLocked ? null : onChanged,
      decoration: _inputDecor("Pilih Opsi", fillColor),
      validator: (val) => val == null ? "Wajib dipilih" : null,
    );
  }
}