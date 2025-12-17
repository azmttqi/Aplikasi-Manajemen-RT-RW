import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LengkapiProfilScreen extends StatefulWidget {
  // Menerima status dari Dashboard untuk logika penguncian
  final String statusVerifikasi;

  const LengkapiProfilScreen({super.key, this.statusVerifikasi = "pending"});

  @override
  State<LengkapiProfilScreen> createState() => _LengkapiProfilScreenState();
}

class _LengkapiProfilScreenState extends State<LengkapiProfilScreen> {
  // --- 1. KONFIGURASI API (Ganti IP di sini saja) ---
  // Gunakan 10.0.2.2 jika Emulator, atau IP Laptop (misal 192.168.1.5) jika HP fisik
  final String baseUrl = "http://localhost:5000/api";

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isLocked = false; // Variabel penentu apakah form dikunci

  // Controller
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _pekerjaanController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();

  // Variable Dropdown
  String? _selectedGender;
  String? _selectedAgama;
  String? _selectedStatusKawin;
  String? _selectedGolDarah;
  String? _selectedKewarganegaraan;

  // List Data
  final List<String> _genderList = ["Laki-laki", "Perempuan"];
  final List<String> _agamaList = ["Islam", "Kristen", "Katolik", "Hindu", "Buddha", "Konghucu"];
  final List<String> _statusList = ["Belum Kawin", "Kawin", "Cerai Hidup", "Cerai Mati"];
  final List<String> _darahList = ["A", "B", "AB", "O", "-"];
  final List<String> _wniList = ["WNI", "WNA"];

  @override
  void initState() {
    super.initState();
    _checkLockStatus(); // Cek status dulu
    _fetchUserData();
  }

  // --- PERBAIKAN PENTING: MEMBERSIHKAN MEMORI ---
  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    _tempatLahirController.dispose();
    _pekerjaanController.dispose();
    _tanggalLahirController.dispose();
    super.dispose();
  }

  // --- CEK STATUS VERIFIKASI ---
  void _checkLockStatus() {
    final status = widget.statusVerifikasi.toLowerCase().trim();
    // Jika verified/disetujui/1, maka KUNCI form
    if (status == 'verified' || status == 'disetujui' || status == '1') {
      setState(() {
        _isLocked = true;
      });
    }
  }

  // --- 2. FUNGSI AMBIL DATA (GET /me) ---
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

      // Cek apakah widget masih aktif sebelum update UI
      if (!mounted) return;

      print("GET Data Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'] ?? jsonResponse;

        if (data != null) {
          setState(() {
            _nikController.text = data['nik'] ?? '';
            _namaController.text = data['nama_lengkap'] ?? '';
            _tempatLahirController.text = data['tempat_lahir'] ?? '';
            _pekerjaanController.text = data['pekerjaan'] ?? '';

            if (data['tanggal_lahir'] != null) {
              String rawDate = data['tanggal_lahir'].toString();
              _tanggalLahirController.text = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;
            }

            _selectedGender = _validateDropdown(data['jenis_kelamin'], _genderList);
            _selectedAgama = _validateDropdown(data['agama'], _agamaList);
            _selectedStatusKawin = _validateDropdown(data['status_perkawinan'], _statusList);
            _selectedGolDarah = _validateDropdown(data['golongan_darah'], _darahList);
            _selectedKewarganegaraan = _validateDropdown(data['kewarganegaraan'], _wniList);
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
    // Logout atau kembali ke login bisa ditangani di sini
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

  // --- 3. FUNGSI SUBMIT (PUT /update-data) ---
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
        'pekerjaan': _pekerjaanController.text,
        'status_perkawinan': _selectedStatusKawin,
        'golongan_darah': _selectedGolDarah,
        'kewarganegaraan': _selectedKewarganegaraan,
      };

      print("Mengirim Data: $dataKirim");

      final response = await http.put(
        Uri.parse('$baseUrl/warga/update-data'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(dataKirim),
      );

      // Cek apakah widget masih aktif sebelum lanjut
      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil disimpan! ✅"), backgroundColor: Colors.green),
        );
        // PENTING: Kirim 'true' agar dashboard merefresh data
        Navigator.pop(context, true);
      } else {
        throw Exception("Gagal simpan: ${response.body}");
      }
    } catch (e) {
      print("Error Submit: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan data: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 4. TAMPILAN UI ---
  @override
  Widget build(BuildContext context) {
    // Tentukan warna dan status input berdasarkan _isLocked
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
                    // --- BANNER INFORMASI JIKA TERKUNCI ---
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
                      enabled: !_isLocked, // Kunci jika verified
                      decoration: _inputDecor("Nama Lengkap", inputColor),
                      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 15),

                    _buildLabel("NIK"),
                    TextFormField(
                      controller: _nikController,
                      enabled: !_isLocked, // Kunci jika verified
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
                      onTap: _isLocked ? null : () async { // Disable tap jika locked
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
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      items: _genderList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: _isLocked ? null : (val) => setState(() => _selectedGender = val),
                      decoration: _inputDecor("Pilih Jenis Kelamin", inputColor),
                      validator: (val) => val == null ? "Wajib dipilih" : null,
                    ),
                    const SizedBox(height: 15),

                    _buildLabel("Agama"),
                    DropdownButtonFormField<String>(
                      value: _selectedAgama,
                      items: _agamaList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: _isLocked ? null : (val) => setState(() => _selectedAgama = val),
                      decoration: _inputDecor("Pilih Agama", inputColor),
                      validator: (val) => val == null ? "Wajib dipilih" : null,
                    ),
                    const SizedBox(height: 15),

                    _buildLabel("Pekerjaan"),
                    TextFormField(
                      controller: _pekerjaanController,
                      enabled: !_isLocked,
                      decoration: _inputDecor("Contoh: Karyawan Swasta", inputColor),
                      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 15),

                    _buildLabel("Status Perkawinan"),
                    DropdownButtonFormField<String>(
                      value: _selectedStatusKawin,
                      items: _statusList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: _isLocked ? null : (val) => setState(() => _selectedStatusKawin = val),
                      decoration: _inputDecor("Pilih Status", inputColor),
                      validator: (val) => val == null ? "Wajib dipilih" : null,
                    ),
                    const SizedBox(height: 15),

                    _buildLabel("Golongan Darah (Opsional)"),
                    DropdownButtonFormField<String>(
                      value: _selectedGolDarah,
                      items: _darahList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: _isLocked ? null : (val) => setState(() => _selectedGolDarah = val),
                      decoration: _inputDecor("Pilih Golongan Darah", inputColor),
                    ),
                    const SizedBox(height: 15),

                    _buildLabel("Kewarganegaraan"),
                    DropdownButtonFormField<String>(
                      value: _selectedKewarganegaraan,
                      items: _wniList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: _isLocked ? null : (val) => setState(() => _selectedKewarganegaraan = val),
                      decoration: _inputDecor("Pilih Kewarganegaraan", inputColor),
                    ),

                    const SizedBox(height: 30),

                    // TOMBOL SIMPAN
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
      disabledBorder: OutlineInputBorder( // Style saat disabled (locked)
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
}