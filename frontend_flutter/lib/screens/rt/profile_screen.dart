import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../auth/login_page.dart'; // Pastikan path ke login_page benar

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Variabel Data User
  String _nama = "Memuat...";
  String _username = "-";
  String _email = "-";
  String _role = "RT"; // Default RT
  String _wilayah = "-";
  String _kodeUnik = "-";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // 1. Ambil Data Profil dari Backend
  void _fetchProfile() async {
    final result = await ApiService.getMe();
    if (mounted) {
      if (result != null) {
        setState(() {
          _nama = result['nama_lengkap'] ?? result['username'] ?? "Ketua RT";
          _username = result['username'] ?? "-";
          _email = result['email'] ?? "-";
          _role = result['role'] ?? "RT";
          _wilayah = result['nomor_wilayah'] ?? "-"; // Biasanya "RT 001"
          _kodeUnik = result['kode_unik'] ?? "-";
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  // 2. Fungsi Logout
  void _handleLogout() async {
    // Tampilkan konfirmasi dulu
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Keluar Aplikasi?"),
        content: const Text("Anda harus login ulang untuk masuk kembali."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
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

  // 3. Fungsi Menampilkan Dialog Edit (Sama persis dengan RW)
  void _showUpdateDialog({required String type}) {
    final TextEditingController currentPassController = TextEditingController();
    final TextEditingController newValueController = TextEditingController();
    
    String title = type == 'password' ? "Ubah Kata Sandi" : "Ubah Data Akun";
    String label = type == 'password' ? "Kata Sandi Baru" : "Email / Username Baru";
    
    // Isi otomatis jika edit info biasa
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
                  // Input Password Lama (Wajib)
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
                  onPressed: isSubmitting
                      ? null
                      : () async {
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

                          // PANGGIL API UPDATE
                          final result = await ApiService.updateProfile(
                            currentPassword: currentPassController.text,
                            newPassword: newPass,
                            newEmail: newEmail,
                            newUsername: newUsername,
                          );

                          setStateDialog(() => isSubmitting = false);
                          Navigator.pop(context); // Tutup Dialog

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
                      : const Text("Simpan"),
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
              
              // --- HEADER FOTO & NAMA ---
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 60, color: Colors.green),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),
              Text(
                _nama, 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  "Ketua $_role $_wilayah", // Contoh: Ketua RT RT 001
                  style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              
              const SizedBox(height: 30),

              // --- KARTU INFO WILAYAH ---
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.location_on, "Wilayah", "RT $_wilayah"),
                    const Divider(),
                    _buildInfoRow(Icons.vpn_key, "Kode Unik (Login)", _kodeUnik),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- MENU PENGATURAN (ListTile) ---
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

                    // 3. Password
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
              const Text("Versi Aplikasi 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Baris Info Wilayah
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.green[700]),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Menu Pengaturan
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