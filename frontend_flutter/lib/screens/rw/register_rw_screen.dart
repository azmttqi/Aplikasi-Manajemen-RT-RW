import 'package:flutter/material.dart';
import 'dart:math'; // 1. Import Math untuk generate kode acak
import '../../../services/api_service.dart'; // 2. Import Service API

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
  
  // Data Wilayah
  final _nomorRwController = TextEditingController();
  final _namaKetuaController = TextEditingController(); // (Opsional, biasanya sama dgn nama akun)
  final _alamatController = TextEditingController();
  final _kodeUnikController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isKonfirmasiPasswordHidden = true;
  bool _isLoading = false; // 3. State untuk loading

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

  // --- FUNGSI GENERATE KODE UNIK ---
  void _generateCode() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    Random rnd = Random();
    // Membuat 5 karakter acak
    String randomStr = String.fromCharCodes(Iterable.generate(
        5, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
    
    setState(() {
      // Format Kode: RW-[ACAK]
      _kodeUnikController.text = "RW-$randomStr";
    });
  }

  // --- FUNGSI PROSES REGISTER ---
  void _handleRegister() async {
    // 1. Validasi Password
    if (_passwordController.text != _konfirmasiPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi kata sandi tidak cocok!"), backgroundColor: Colors.red),
      );
      return;
    }

    // 2. Validasi Kolom Kosong
    if (_namaController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _nomorRwController.text.isEmpty ||
        _kodeUnikController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap lengkapi semua data utama & Generate Kode!"), backgroundColor: Colors.red),
      );
      return;
    }

    // Mulai Loading
    setState(() => _isLoading = true);

    // 3. Panggil API Service
    final result = await ApiService.register(
      role: 'RW',
      namaLengkap: _namaController.text,
      email: _emailController.text,
      // Buat username otomatis dari bagian depan email (misal budi@gmail.com -> budi)
      username: _emailController.text.split('@')[0], 
      password: _passwordController.text,
      
      // Data Wilayah RW
      nomorWilayah: _nomorRwController.text,
      alamatWilayah: _alamatController.text,
      kodeWilayahBaru: _kodeUnikController.text, // Kode yang digenerate
    );

    // Stop Loading
    setState(() => _isLoading = false);

    // 4. Cek Hasil
    if (result['success']) {
      // Jika Sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi RW Berhasil! Silakan Login."))
      );
      // Kembali ke halaman Login (Route paling awal)
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      // Jika Gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBE6), // Background cream
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
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(child: _buildLogoSection()),
                const SizedBox(height: 32),

                const Text(
                  "Pendaftaran Super Admin RW & Kode Wilayah",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 24),

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
                const SizedBox(height: 24),

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
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    // Jika Loading, tombol mati (null) agar tidak diklik 2x
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

                _buildLoginLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER (SAMA SEPERTI SEBELUMNYA) ---

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
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            width: 130,
            child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.all(12),
                filled: true,
                fillColor: Colors.grey[200],
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
            width: 130,
            child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: true,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.all(12),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[100],
              foregroundColor: Colors.blue[800],
              padding: const EdgeInsets.symmetric(horizontal: 10),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            onPressed: _generateCode, // Memanggil fungsi generate
            child: const Text("Generated Code"),
          )
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Icon(Icons.home_work_rounded, size: 80, color: Colors.green[800]),
        const SizedBox(height: 8),
        Text("Manajemen RT/RW", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[900])),
        Text("Membangun Komunitas Cerdas", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Sudah Punya akun?", style: TextStyle(color: Colors.grey[700])),
        TextButton(
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          child: const Text("Login", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}