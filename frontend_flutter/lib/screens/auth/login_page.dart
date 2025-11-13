import 'package:flutter/material.dart';
import './register_screen.dart'; // Import halaman registrasi
import './forgot_password_screen.dart'; // Import file baru 

// 1. Nama class-nya adalah LoginPage, sesuai nama file
class LoginPage extends StatefulWidget {
  static const String routeName = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // State untuk mengontrol visibilitas password
  bool _isPasswordHidden = true;

  // State untuk menampilkan pesan error
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Kita gunakan bottomNavigationBar untuk footer agar selalu menempel di bawah
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
      // Gunakan SingleChildScrollView agar layar bisa di-scroll
      // saat keyboard muncul
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60), // Jarak dari atas

              // --- 1. Logo dan Tagline ---
              _buildLogoSection(),

              const SizedBox(height: 40),

              // --- 2. Input Username ---
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Username",
                  hintText: "masukan username anda",
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              // --- 3. Input Password ---
              TextFormField(
                obscureText: _isPasswordHidden, // Gunakan state
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "masukan password anda",
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordHidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      // Update state untuk toggle visibilitas
                      setState(() {
                        _isPasswordHidden = !_isPasswordHidden;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // --- 4. Pesan Error (Opsional) ---
              // Tampilkan widget ini jika state _showError == true
              if (_showError) _buildErrorBanner(),

              const SizedBox(height: 24),

              // --- 5. Tombol Login ---
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
                  // TODO: Tambahkan logika login di sini
                  setState(() {
                    _showError = true; // Tampilkan error saat login gagal
                  });
                },
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 24),

              // --- 6. Link Lupa Password & Daftar ---
              _buildFooterLinks(), // Memanggil fungsi yang sudah benar
            ],
          ),
        ),
      ),
    );
  }

  // Widget terpisah untuk bagian Logo
  Widget _buildLogoSection() {
    return Column(
      children: [
        // GANTI INI DENGAN LOGO ANDA
        // Gunakan Image.asset('assets/images/logo.png') jika punya file gambar
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

  // Widget terpisah untuk banner error
  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFDC3545), // Warna merah
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 10),
          Text(
            "username atau password salah.",
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  //
  // --- INI BAGIAN YANG DIPERBAIKI ---
  //
 Widget _buildFooterLinks() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      TextButton(
        onPressed: () {
          // GANTI TODO ANDA DENGAN INI:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
          );
        },
        child: const Text(
          "Lupa Password?",
          style: TextStyle(color: Colors.blue, fontSize: 14),
          ),
        ),
        Text(
          "|", // Pemisah sederhana
          style: TextStyle(color: Colors.grey[400]),
        ),
        TextButton(
          onPressed: () {
            // INI ADALAH LOGIKA NAVIGASI YANG BENAR
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: const Text(
            "Daftar Sekarang",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold, // Dibuat bold seperti di gambar
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}