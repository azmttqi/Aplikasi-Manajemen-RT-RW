import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../rw/main_screen.dart';
import '../rt/rt_main_screen.dart';
import '../warga/warga_main_screen.dart';

// Import Widget Logo (Pastikan file ini sudah dibuat di lib/widgets/logo_widget.dart)
import '../../widgets/logo_widget.dart'; 

import './register_screen.dart';
import './forgot_password_screen.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordHidden = true;
  bool _showError = false;
  String _errorText = "username atau password salah.";

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _showError = false;
    });

    final identifier = _usernameController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _showError = true;
        _errorText = "Username dan password wajib diisi.";
      });
      return;
    }

    final result = await ApiService.login(identifier, password);

    if (!mounted) return;

    if (result['success'] == true) {
      final role = result['role'] as String;

      if (role == "RW") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => RwMainScreen()),
        );
      } else if (role == 'RT') {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const RtMainScreen()),
        );
      } else if (role == "Warga") {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const WargaMainScreen()),
        );
      } else {
        setState(() {
          _showError = true;
          _errorText = "Peran tidak dikenali.";
        });
      }

      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _showError = true;
        _errorText = (result['message'] ?? "Login gagal.").toString();
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Tambahkan background putih bersih
      bottomNavigationBar: Container(
        height: 50,
        color: const Color(0xFF678267),
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
      body: Center( // Tambahkan Center agar konten di tengah vertikal
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                // --- BAGIAN LOGO (DIPERBAIKI) ---
                // Kita gunakan LogoWidget agar seragam.
                // Jika belum buat widgetnya, ganti baris ini dengan Image.asset(...)
                const Center(
                  child: LogoWidget(
                    height: 220, // Ukuran logo di halaman login
                    width: 220,
                  ),
                ),
                // -------------------------------

                const SizedBox(height: 0),

                // --- Username ---
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Username / Email",
                    hintText: "Masukkan username anda",
                    prefixIcon: Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                // --- Password ---
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordHidden,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Masukkan password anda",
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordHidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordHidden = !_isPasswordHidden;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                if (_showError) _buildErrorBanner(),

                const SizedBox(height: 24),

                // --- Tombol Login ---
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF678267), // Sesuaikan warna dengan tema (Hijau)
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 24),

                _buildFooterLinks(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFDC3545),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorText,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ForgotPasswordScreen(),
              ),
            );
          },
          child: const Text(
            "Lupa Password?",
            style: TextStyle(color: Color(0xFF678267), fontSize: 14),
          ),
        ),
        Text(
          "|",
          style: TextStyle(color: Colors.grey[400]),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterScreen(),
              ),
            );
          },
          child: const Text(
            "Daftar Sekarang",
            style: TextStyle(
              color: Color(0xFF678267),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}