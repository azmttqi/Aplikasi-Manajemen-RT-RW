import 'package:flutter/material.dart';
import 'dart:math'; 
import '../../../services/api_service.dart';
import '../../widgets/logo_widget.dart'; 

class RegisterRtScreen extends StatefulWidget {
  const RegisterRtScreen({super.key});

  @override
  State<RegisterRtScreen> createState() => _RegisterRtScreenState();
}

class _RegisterRtScreenState extends State<RegisterRtScreen> {
  // 1. Deklarasi Controller (Wajib Lengkap)
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _noRtController = TextEditingController();
  final _alamatController = TextEditingController();
  final _kodeUnikWilayahController = TextEditingController(); 
  final _kodeRwIndukController = TextEditingController(); 

  bool _isLoading = false;

  // 2. Variabel untuk Status Mata Password (Ini yang sering bikin error kalau lupa)
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _noRtController.dispose();
    _alamatController.dispose();
    _kodeUnikWilayahController.dispose();
    _kodeRwIndukController.dispose();
    super.dispose();
  }

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

    setState(() => _isLoading = true);

    // 2. PENGGUNAAN API SERVICE (Agar warna kuning hilang)
    final result = await ApiService.register(
      role: 'RT',
      namaLengkap: _namaController.text,
      email: _emailController.text,
      username: _emailController.text.split('@')[0], 
      password: _passwordController.text,
      nomorWilayah: _noRtController.text,
      alamatWilayah: _alamatController.text,
      kodeWilayahBaru: _kodeUnikWilayahController.text,
      kodeInduk: _kodeRwIndukController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi RT Berhasil!"))
      );
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E5), // Background cream
      
      // --- APPBAR: Judul Sejajar Tombol Back (Sesuai Permintaan) ---
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F2E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          "Pendaftaran Admin RT",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            const Center(child: LogoWidget(height: 180, width: 180)),
            const SizedBox(height: 20),

            _buildSectionTitle("Data Akun Admin RT"),
            _buildCard(
              children: [
                _buildTextField("Nama Lengkap", _namaController),
                _buildTextField("Email", _emailController, inputType: TextInputType.emailAddress),
                
                // Field Password + Tombol Mata
                _buildTextField(
                  "Kata Sandi", 
                  _passwordController, 
                  isPassword: _isPasswordHidden,
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordHidden ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
                  ),
                ),
                
                // Field Konfirmasi + Tombol Mata
                _buildTextField(
                  "Konfirmasi Kata Sandi", 
                  _confirmPasswordController, 
                  isPassword: _isConfirmPasswordHidden,
                  suffixIcon: IconButton(
                    icon: Icon(_isConfirmPasswordHidden ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isConfirmPasswordHidden = !_isConfirmPasswordHidden),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            _buildSectionTitle("Data Wilayah RT"),
            _buildCard(
              children: [
                _buildTextField("Nomor RT", _noRtController, inputType: TextInputType.number),
                _buildTextField("Alamat/Wilayah RT", _alamatController),
                Row(
                  children: [
                    Expanded(child: _buildTextField("Kode Unik", _kodeUnikWilayahController, readOnly: true)),
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
            _buildSectionTitle("Verifikasi"),
            _buildCard(
              children: [
                _buildTextField("Kode Unik RW (Wajib)", _kodeRwIndukController),
              ],
            ),

            const SizedBox(height: 30),
            _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF678267),
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    child: const Text("Daftar", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS (PASTIKAN BAGIAN INI TER-COPY SEMUA) ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 5),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, {
    bool isPassword = false, 
    TextInputType inputType = TextInputType.text, 
    bool readOnly = false,
    Widget? suffixIcon, // Parameter kunci untuk fitur mata
  }) {
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
          fillColor: Colors.grey[100],
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          suffixIcon: suffixIcon, // Memasukkan icon mata ke sini
        ),
      ),
    );
  }
}