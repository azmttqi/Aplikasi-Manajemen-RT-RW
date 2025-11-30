import 'package:flutter/material.dart';
import 'dart:math'; // Untuk generate kode acak
import '../../../services/api_service.dart';

class RegisterRtScreen extends StatefulWidget {
  const RegisterRtScreen({super.key});

  @override
  State<RegisterRtScreen> createState() => _RegisterRtScreenState();
}

class _RegisterRtScreenState extends State<RegisterRtScreen> {
  // --- Controller Data Akun ---
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // --- Controller Data Wilayah ---
  final _noRtController = TextEditingController();
  final _alamatController = TextEditingController();
  final _kodeUnikWilayahController = TextEditingController(); // Kode Baru (Generated)
  final _kodeRwIndukController = TextEditingController(); // Kode RW (Input)

  bool _isLoading = false;

  // Fungsi Generate Kode Unik (Misal: RT-X7Z9)
  void _generateCode() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    Random rnd = Random();
    String result = String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
    
    setState(() {
      _kodeUnikWilayahController.text = "RT-$result";
    });
  }

  void _handleRegister() async {
    // 1. Validasi Password
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi password tidak cocok!"), backgroundColor: Colors.red),
      );
      return;
    }

    // 2. Validasi Kolom Kosong
    if (_namaController.text.isEmpty || _kodeRwIndukController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap lengkapi semua data!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 3. Panggil API
    final result = await ApiService.register(
      role: 'RT',
      namaLengkap: _namaController.text,
      email: _emailController.text,
      username: _emailController.text.split('@')[0], // Username otomatis dari email
      password: _passwordController.text,
      
      // Data Wilayah
      nomorWilayah: _noRtController.text,
      alamatWilayah: _alamatController.text,
      kodeWilayahBaru: _kodeUnikWilayahController.text,
      
      // Validasi Induk (Kode RW)
      kodeInduk: _kodeRwIndukController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registrasi RT Berhasil! Silakan Login.")));
      Navigator.pop(context); // Balik ke menu utama
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBE6), // Background cream sesuai desain
      appBar: AppBar(title: const Text("Pendaftaran Admin RT"), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN 1: DATA AKUN ---
            _buildSectionTitle("Data Akun Admin RT"),
            _buildCard(
              children: [
                _buildTextField("Nama Lengkap", _namaController),
                _buildTextField("Email", _emailController, inputType: TextInputType.emailAddress),
                _buildTextField("Kata Sandi", _passwordController, isPassword: true),
                _buildTextField("Konfirmasi Kata Sandi", _confirmPasswordController, isPassword: true),
              ],
            ),
            
            const SizedBox(height: 20),

            // --- BAGIAN 2: DATA WILAYAH ---
            _buildSectionTitle("Data Wilayah RT"),
            _buildCard(
              children: [
                _buildTextField("Nomor RT", _noRtController, inputType: TextInputType.number),
                _buildTextField("Alamat/Wilayah RT", _alamatController),
                
                // Row untuk Kode Unik + Tombol Generate
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField("Kode Unik", _kodeUnikWilayahController, readOnly: true),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _generateCode,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text("Generate", style: TextStyle(fontSize: 10, color: Colors.white)),
                    )
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            
            // --- BAGIAN 3: KODE RW ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: TextField(
                controller: _kodeRwIndukController,
                decoration: const InputDecoration(border: InputBorder.none, labelText: "Kode Unik RW (Wajib Diisi)"),
              ),
            ),

            const SizedBox(height: 30),

            _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.all(15)),
                    child: const Text("Daftar", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(children: children),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false, TextInputType inputType = TextInputType.text, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: inputType,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}