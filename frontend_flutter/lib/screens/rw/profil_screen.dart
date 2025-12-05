import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../auth/login_page.dart';// Pastikan path ini benar sesuai struktur folder Anda

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
  String _role = "-";
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
          _nama = result['nama_lengkap'] ?? result['username'] ?? "User";
          _username = result['username'] ?? "-";
          _email = result['email'] ?? "-";
          _role = result['role'] ?? "Warga";
          _wilayah = result['nomor_wilayah'] ?? "-";
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
    await ApiService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // 3. Fungsi Menampilkan Dialog Edit (Password / Info)
  void _showUpdateDialog({required String type}) {
    final TextEditingController currentPassController = TextEditingController();
    final TextEditingController newValueController = TextEditingController();
    
    String title = type == 'password' ? "Ubah Kata Sandi" : "Ubah Data Akun";
    String label = type == 'password' ? "Kata Sandi Baru" : "Email / Username Baru";
    
    // Jika edit info, isi otomatis dengan data saat ini
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
                    obscureText: type == 'password', // Jika ganti password, tutup teksnya
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

                          // Siapkan data untuk dikirim
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

                          // Tampilkan Hasil
                          if (result['success']) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Berhasil diperbarui! ✅")));
                            _fetchProfile(); // Refresh data di layar
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profil Saya", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- HEADER FOTO ---
            const SizedBox(height: 10),
            Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.person, size: 60, color: Colors.green),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      // Fitur Ganti Foto (Nanti saja)
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 15),
            Text(_nama, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(_role, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
            
            const SizedBox(height: 30),

            // --- INFO WILAYAH (Card) ---
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.location_on, "Wilayah", _wilayah),
                  const Divider(),
                  _buildInfoRow(Icons.vpn_key, "Kode Unik", _kodeUnik),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- MENU OPSI ---
            // 1. Ubah Username
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.person_outline, color: Colors.blue),
              ),
              title: const Text("Username"),
              subtitle: Text(_username),
              trailing: const Icon(Icons.edit, size: 16, color: Colors.grey),
              onTap: () => _showUpdateDialog(type: 'username'), // Aksi Ubah Username
            ),
            
            // 2. Ubah Email
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.purple[50], borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.email_outlined, color: Colors.purple),
              ),
              title: const Text("Email"),
              subtitle: Text(_email),
              trailing: const Icon(Icons.edit, size: 16, color: Colors.grey),
              onTap: () => _showUpdateDialog(type: 'email'), // Aksi Ubah Email
            ),

            // 3. Ubah Password
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.lock_outline, color: Colors.orange),
              ),
              title: const Text("Kata Sandi"),
              subtitle: const Text("Ketuk untuk mengubah"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () => _showUpdateDialog(type: 'password'), // Aksi Ubah Password
            ),

            const Divider(height: 30),

            // 4. Logout
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.logout, color: Colors.red),
              ),
              title: const Text("Keluar Akun", style: TextStyle(color: Colors.red)),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  // Widget kecil untuk baris info
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green[700]),
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
}