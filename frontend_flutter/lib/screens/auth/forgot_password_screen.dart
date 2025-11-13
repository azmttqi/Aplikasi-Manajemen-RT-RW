import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Footer yang sama
      bottomNavigationBar: Container(
        height: 50,
        color: const Color(0xFF678267), // Warna hijau footer
        child: const Center(
          child: Text(
            "©2025 Lingkar Warga App",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
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

              // --- 1. Logo (sama seperti login) ---
              _buildLogoSection(),

              const SizedBox(height: 40),

              // --- 2. Judul ---
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

              // --- 3. Sub-Judul ---
              Text(
                "Masukkan email Anda dan kami akan mengirimkan tautan untuk mengatur ulang kata sandi Anda.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange[800], // Warna oranye
                ),
              ),

              const SizedBox(height: 32),

              // --- 4. Input Email ---
              TextFormField(
                // Tema styling sudah diatur di main.dart
                decoration: const InputDecoration(
                  hintText: "Alamat Email Terdaftar",
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 24),

              // --- 5. Tombol Kirim Tautan ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Warna biru
                  foregroundColor: Colors.white, // Warna teks putih
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () {
                  // TODO: Tambahkan logika kirim email reset password
                  Navigator.pop(context);
                },
                child: const Text(
                  "Kirim Tautan Reset",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 16),

              // --- 6. Link Kembali ke Login ---
              TextButton(
                onPressed: () {
                  // Aksi ini akan menutup halaman ini
                  // dan kembali ke halaman sebelumnya (Login)
                  Navigator.pop(context);
                },
                child: Text(
                  "Kembali ke Halaman Login",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget terpisah untuk bagian Logo
  // (Sama seperti di login_page.dart)
  Widget _buildLogoSection() {
    return Column(
      children: [
        Icon(
          Icons.home_work_rounded,
          size: 80,
          color: Colors.green[800],
        ),
        const SizedBox(height: 8),
        Text(
          "Manajemen RT/RW",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
        ),
        Text(
          "Membangun Komunitas Cerdas",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}