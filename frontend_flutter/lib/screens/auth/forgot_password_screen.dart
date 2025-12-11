import 'package:flutter/material.dart';
// Import Widget Logo Baru
import '../../widgets/logo_widget.dart'; 

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih bersih
      
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

              // --- 1. Logo (SUDAH DIPERBAIKI) ---
              // Menggunakan LogoWidget agar konsisten
              const Center(
                child: LogoWidget(
                  height: 200,
                  width: 200,
                ),
              ),

              const SizedBox(height: 0),

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
                  color: Colors.grey[700], // Warna abu-abu agar lebih elegan
                ),
              ),

              const SizedBox(height: 32),

              // --- 4. Input Email ---
              TextFormField(
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

              // --- 5. Tombol Kirim Tautan ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF678267), // Ubah jadi HIJAU (Tema Logo)
                  foregroundColor: Colors.white,
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
                  // Kembali ke halaman sebelumnya (Login)
                  Navigator.pop(context);
                },
                child: const Text(
                  "Kembali ke Halaman Login",
                  style: TextStyle(
                    color: Color(0xFF678267), // Ubah jadi Hijau juga
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