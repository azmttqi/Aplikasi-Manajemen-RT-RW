import 'package:flutter/material.dart';
import '../rw/register_rw_screen.dart'; // Import file baru Anda

// Enum untuk melacak peran yang dipilih
enum UserRole { rw, rt, warga }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // State untuk menyimpan peran mana yang di-klik
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Footer yang sama dengan login
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

              // --- 2. Pilihan Peran ---
              _buildRoleCard(
                role: UserRole.rw,
                title: "Daftar RW Baru",
                subtitle: "Dapatkan kemudahan mengelola administrasi kependudukan",
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                role: UserRole.rt,
                title: "Daftar RT Baru",
                subtitle: "Dapatkan kemudahan mengelola administrasi kependudukan",
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                role: UserRole.warga,
                title: "Daftar Warga Baru",
                subtitle: "Dapatkan kemudahan mengurus administrasi kependudukan",
              ),

              const SizedBox(height: 32),

              // --- 3. Tombol Lanjut ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  // Tombol akan nonaktif jika _selectedRole masih null
                  disabledBackgroundColor: Colors.grey[400],
                ),
                // Logika utama:
                // Jika _selectedRole adalah null, onPressed juga null (tombol mati)
                // Jika sudah dipilih, tombol akan aktif
                onPressed: _selectedRole == null
                    ? null
                    : () {
                        // TODO: Navigasi ke halaman detail pendaftaran
                        // Anda bisa cek perannya di sini:
                        // if (_selectedRole == UserRole.rt) { ... }
                        print("Peran yang dipilih: $_selectedRole");
                      },
                child: const Text(
                  "Lanjut",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 24),

              // --- 4. Link Login ---
              _buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk membuat kartu pilihan peran
  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String subtitle,
  }) {
    // Cek apakah kartu ini sedang dipilih
    final bool isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        // Update state saat kartu di-klik
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 30,
              color: isSelected ? Colors.blue : Colors.grey[600],
            ),
            const SizedBox(width: 16),
            // Expanded agar teks tidak overflow
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.blue : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk link "Sudah Punya akun? Login"
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Sudah Punya akun?",
          style: TextStyle(color: Colors.grey[700]),
        ),
        TextButton(
          onPressed: () {
            // Kembali ke halaman sebelumnya (Login)
            Navigator.pop(context);
          },
          child: const Text(
            "Login",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Widget untuk Logo (bisa di-copas dari login_page.dart)
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