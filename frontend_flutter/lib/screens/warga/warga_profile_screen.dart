import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../auth/login_page.dart';

class WargaProfileScreen extends StatefulWidget {
  const WargaProfileScreen({super.key});

  @override
  State<WargaProfileScreen> createState() => _WargaProfileScreenState();
}

class _WargaProfileScreenState extends State<WargaProfileScreen> {
  // Variabel Data
  String _nama = "Memuat...";
  String _username = "-";
  String _email = "-";
  // ignore: unused_field
  String _role = "Warga"; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // 1. Ambil Data Profil
  void _fetchProfile() async {
    final result = await ApiService.getMe();
    if (mounted) {
      if (result != null) {
        setState(() {
          _nama = result['nama_lengkap'] ?? "Warga";
          _username = result['username'] ?? "-";
          _email = result['email'] ?? "-";
          _role = result['role'] ?? "Warga";
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  // 2. Fungsi Logout
  void _handleLogout() async {
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

  // 3. Dialog Update Data (Logic sama persis dengan RT)
  void _showUpdateDialog({required String type}) {
    final TextEditingController currentPassController = TextEditingController();
    final TextEditingController newValueController = TextEditingController();
    
    String title = type == 'password' ? "Ubah Kata Sandi" : "Ubah Data Akun";
    String label = type == 'password' ? "Kata Sandi Baru" : "Email / Username Baru";
    
    if (type == 'email') newValueController.text = _email;
    if (type == 'username') newValueController.text = _username;

    showDialog(
      context: context,
      builder: (context) {
        bool isSubmitting = false;
        
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Demi keamanan, masukkan kata sandi lama Anda:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 10),
                  // Input Password Lama
                  TextField(
                    controller: currentPassController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Kata Sandi Lama",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Input Data Baru
                  TextField(
                    controller: newValueController,
                    obscureText: type == 'password', 
                    decoration: InputDecoration(
                      labelText: label,
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(type == 'password' ? Icons.vpn_key : Icons.edit),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    // Validasi input kosong
                    if (currentPassController.text.isEmpty || newValueController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Mohon isi semua kolom")));
                      return;
                    }

                    setStateDialog(() => isSubmitting = true);

                    String? newPass, newEmail, newUsername;
                    if (type == 'password') newPass = newValueController.text;
                    if (type == 'email') newEmail = newValueController.text;
                    if (type == 'username') newUsername = newValueController.text;

                    // Panggil API Update (Menggunakan fungsi yang sama dengan RT)
                    final result = await ApiService.updateProfile(
                      currentPassword: currentPassController.text,
                      newPassword: newPass,
                      newEmail: newEmail,
                      newUsername: newUsername,
                    );

                    setStateDialog(() => isSubmitting = false);
                    Navigator.pop(context); // Tutup dialog

                    if (result['success']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Berhasil diperbarui! ✅"), backgroundColor: Colors.green));
                      _fetchProfile(); // Refresh tampilan
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result['message']), backgroundColor: Colors.red));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Simpan", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Background Cream
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              
              // --- HEADER FOTO (Tanpa Tombol Kamera) ---
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 60, color: Colors.green),
              ),
              const SizedBox(height: 15),
              Text(
                _nama, 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                "@$_username", 
                style: const TextStyle(color: Colors.grey),
              ),
              
              const SizedBox(height: 30),

              // --- MENU PENGATURAN ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // 1. Username
                    _buildSettingsTile(
                      icon: Icons.person_outline, 
                      color: Colors.blue, 
                      title: "Username", 
                      subtitle: _username,
                      onTap: () => _showUpdateDialog(type: 'username'),
                    ),
                    const Divider(height: 1),
                    
                    // 2. Email
                    _buildSettingsTile(
                      icon: Icons.email_outlined, 
                      color: Colors.purple, 
                      title: "Email", 
                      subtitle: _email,
                      onTap: () => _showUpdateDialog(type: 'email'),
                    ),
                    const Divider(height: 1),

                    // 3. Password (Poin 3)
                    _buildSettingsTile(
                      icon: Icons.lock_outline, 
                      color: Colors.orange, 
                      title: "Ganti Kata Sandi", 
                      subtitle: "******",
                      onTap: () => _showUpdateDialog(type: 'password'),
                      isArrow: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 4. Logout
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text("Keluar Akun", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 20),
              const Text("Versi Aplikasi 1.0.0 (Warga)", style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon, 
    required Color color, 
    required String title, 
    required String subtitle,
    required VoidCallback onTap,
    bool isArrow = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: isArrow 
          ? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
          : const Icon(Icons.edit, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}