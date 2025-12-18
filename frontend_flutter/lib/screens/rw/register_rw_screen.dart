import 'package:flutter/material.dart';
import 'dart:math'; 
import '../../services/api_service.dart'; 
import '../../widgets/logo_widget.dart'; 

class RegisterRwScreen extends StatefulWidget {
  const RegisterRwScreen({super.key});

  @override
  State<RegisterRwScreen> createState() => _RegisterRwScreenState();
}

class _RegisterRwScreenState extends State<RegisterRwScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiPasswordController = TextEditingController();
  
  final _nomorRwController = TextEditingController();
  final _namaKetuaController = TextEditingController(); 
  final _alamatController = TextEditingController();
  final _kodeUnikController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isKonfirmasiPasswordHidden = true;
  bool _isLoading = false; 

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    _nomorRwController.dispose();
    _namaKetuaController.dispose();
    _alamatController.dispose();
    _kodeUnikController.dispose();
    super.dispose();
  }

  void _generateCode() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    Random rnd = Random();
    String randomStr = String.fromCharCodes(Iterable.generate(
        5, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
    
    setState(() {
      _kodeUnikController.text = "RW-$randomStr";
    });
  }

  void _handleRegister() async {
    if (_passwordController.text != _konfirmasiPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi kata sandi tidak cocok!"), backgroundColor: Colors.red),
      );
      return;
    }

    if (_namaController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _nomorRwController.text.isEmpty ||
        _kodeUnikController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap lengkapi semua data utama & Generate Kode!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.register(
      role: 'RW',
      namaLengkap: _namaController.text,
      email: _emailController.text,
      username: _emailController.text.split('@')[0], 
      password: _passwordController.text,
      nomorWilayah: _nomorRwController.text,
      alamatWilayah: _alamatController.text,
      kodeWilayahBaru: _kodeUnikController.text, 
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi RW Berhasil! Silakan Login."))
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBE6), // Background cream
      
      // --- PERUBAHAN DI SINI: MENAMBAHKAN APPBAR ---
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBE6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0, // Agar judul lebih dekat dengan tombol back
        title: const Text(
          "Pendaftaran Super Admin RW",
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold, 
            color: Colors.black87
          ),
        ),
      ),

      bottomNavigationBar: Container(
        height: 50,
        color: const Color(0xFF678267),
        child: const Center(
          child: Text(
            "©2025 Lingkar Warga App",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo tetap ditampilkan namun dengan padding lebih kecil
                _buildLogoSection(),
                
                const SizedBox(height: 20),

                // --- DATA AKUN ---
                _buildFormCard(
                  title: "Data Akun Super Admin RW",
                  children: [
                    _buildFormRow(label: "Nama Lengkap", controller: _namaController),
                    _buildFormRow(label: "Email", controller: _emailController, keyboardType: TextInputType.emailAddress),
                    _buildFormRow(
                      label: "Kata Sandi",
                      controller: _passwordController,
                      obscureText: _isPasswordHidden,
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                        onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
                      ),
                    ),
                    _buildFormRow(
                      label: "Konfirmasi Kata Sandi",
                      controller: _konfirmasiPasswordController,
                      obscureText: _isKonfirmasiPasswordHidden,
                      suffixIcon: IconButton(
                        icon: Icon(_isKonfirmasiPasswordHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                        onPressed: () => setState(() => _isKonfirmasiPasswordHidden = !_isKonfirmasiPasswordHidden),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- DATA WILAYAH ---
                _buildFormCard(
                  title: "Data Wilayah RW",
                  children: [
                    _buildFormRow(label: "Nomor RW", controller: _nomorRwController, keyboardType: TextInputType.number),
                    _buildFormRow(label: "Nama Ketua RW", controller: _namaKetuaController),
                    _buildFormRow(label: "Alamat/ Wilayah RW", controller: _alamatController),
                    _buildGeneratedCodeField(
                      label: "Kode Unik",
                      controller: _kodeUnikController,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // --- TOMBOL DAFTAR ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF678267), 
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("Daftar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER TETAP SAMA ---
  Widget _buildFormCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const Divider(height: 24, thickness: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFormRow({required String label, TextEditingController? controller, bool obscureText = false, TextInputType? keyboardType, Widget? suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 110, // Sedikit diperkecil agar pas di layar kecil
            child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.all(12),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
                suffixIcon: suffixIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedCodeField({required String label, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: true,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.all(12),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[50],
              foregroundColor: Colors.blue[800],
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            onPressed: _generateCode,
            child: const Text("Generate"),
          )
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return const Center(
      child: LogoWidget(
        height: 180, 
        width: 180,
      ),
    );
  }
}