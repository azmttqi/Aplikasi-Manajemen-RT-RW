import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../auth/login_page.dart';

class WargaProfileScreen extends StatefulWidget {
  const WargaProfileScreen({super.key});

  @override
  State<WargaProfileScreen> createState() => _WargaProfileScreenState();
}

class _WargaProfileScreenState extends State<WargaProfileScreen> {
  String _nama = "Memuat...";
  String _email = "-";
  String _username = "-";
  String _role = "Warga";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final result = await ApiService.getMe();
    if (mounted && result != null) {
      setState(() {
        _nama = result['nama_lengkap'] ?? "Warga";
        _username = result['username'] ?? "-";
        _email = result['email'] ?? "-";
      });
    }
  }

  void _handleLogout() async {
    // Konfirmasi Logout
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Keluar Aplikasi?"),
        content: const Text("Anda harus login ulang nanti."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Background Cream
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // FOTO & NAMA
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 60, color: Colors.green),
              ),
              const SizedBox(height: 15),
              Text(_nama, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text("@$_username", style: const TextStyle(color: Colors.grey)),
              
              const SizedBox(height: 30),

              // MENU OPSI
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildTile(Icons.email_outlined, "Email", _email),
                    const Divider(height: 1),
                    _buildTile(Icons.lock_outline, "Ganti Kata Sandi", "******", isArrow: true),
                    const Divider(height: 1),
                    _buildTile(Icons.help_outline, "Bantuan", "Pusat Bantuan", isArrow: true),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // TOMBOL LOGOUT
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text("Keluar Akun", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                  ),
                ),
              ),
              
               const SizedBox(height: 20),
               const Text("Versi 1.0.0 (Warga)", style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, String subtitle, {bool isArrow = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[700]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: isArrow ? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey) : null,
    );
  }
}