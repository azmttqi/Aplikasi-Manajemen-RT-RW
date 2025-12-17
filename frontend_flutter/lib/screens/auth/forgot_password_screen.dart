import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Tambahan untuk menangani Timeout
import '../../widgets/logo_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // 1. Pengendali Teks
  final TextEditingController _emailController = TextEditingController();
  
  // 2. Status Loading
  bool _sedangLoading = false;

  // --- PERBAIKAN 1: MEMBERSIHKAN MEMORI ---
  @override
  void dispose() {
    _emailController.dispose(); // Wajib dilakukan agar HP tidak berat
    super.dispose();
  }

  // --- FUNGSI UTAMA: MENGHUBUNGKAN KE BACKEND ---
  Future<void> _kirimEmailReset() async {
    // Hilangkan fokus keyboard agar UI lebih rapi saat loading
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();

    // --- PERBAIKAN 2: VALIDASI INPUT LEBIH BAIK ---
    if (email.isEmpty) {
      _tampilkanPesan("Harap isi email terlebih dahulu!", Colors.orange);
      return;
    }
    
    // Cek apakah format email valid (mengandung @ dan .)
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      _tampilkanPesan("Format email tidak valid.", Colors.orange);
      return;
    }

    setState(() {
      _sedangLoading = true;
    });

    try {
      // Setup URL (Sesuaikan IP seperti sebelumnya)
      // Gunakan 10.0.2.2 untuk Emulator, atau IP Laptop untuk Real Device
      final url = Uri.parse('http://localhost:5000/api/auth/forgot-password');

      // --- PERBAIKAN 3: MENAMBAHKAN TIMEOUT ---
      // Jika 10 detik tidak ada respon, anggap koneksi putus
      final respon = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (respon.statusCode == 200) {
        // SUKSES
        _tampilkanPesan("Tautan reset berhasil dikirim! Cek email Anda.", Colors.green);
        Navigator.pop(context);
      } else {
        // GAGAL
        // --- PERBAIKAN 4: CEK FORMAT ERROR DARI SERVER ---
        String pesanError = "Gagal mengirim email.";
        try {
          final dataRespon = jsonDecode(respon.body);
          pesanError = dataRespon['message'] ?? pesanError;
        } catch (_) {
          // Jika server error tapi bukan JSON (misal HTML error 500)
          pesanError = "Terjadi kesalahan pada server (Error ${respon.statusCode})";
        }
        
        _tampilkanPesan(pesanError, Colors.red);
      }
    } on TimeoutException {
      // Error khusus jika koneksi lambat
      if (mounted) _tampilkanPesan("Koneksi internet terlalu lambat (Timeout).", Colors.red);
    } catch (e) {
      // Error umum lainnya
      if (mounted) _tampilkanPesan("Gagal terhubung ke server. Periksa internet Anda.", Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _sedangLoading = false;
        });
      }
    }
  }

  // Helper kecil untuk menampilkan SnackBar agar kodenya tidak berulang-ulang
  void _tampilkanPesan(String pesan, Color warna) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: warna,
        behavior: SnackBarBehavior.floating, // Sedikit lebih modern
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TAMPILAN TIDAK DIUBAH SAMA SEKALI DARI KODE ASLI
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E5),
      
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              const Center(
                child: LogoWidget(height: 200, width: 200),
              ),

              const SizedBox(height: 0),

              const Text(
                "Lupa Kata Sandi",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Masukkan email Anda dan kami akan mengirimkan tautan untuk mengatur ulang kata sandi Anda.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 32),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Alamat Email",
                  hintText: "Masukkan email terdaftar",
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF678267),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: _sedangLoading ? null : _kirimEmailReset,
                child: _sedangLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Kirim Tautan Reset",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Kembali ke Halaman Login",
                  style: TextStyle(
                    color: Color(0xFF678267),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],  
          ),
        ),
      ),
    );
  }
}