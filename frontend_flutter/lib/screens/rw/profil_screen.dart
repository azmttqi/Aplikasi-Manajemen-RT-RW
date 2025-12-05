import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../auth/login_page.dart'; // Pastikan path ke Login Page benar

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _nama = "Memuat...";
  String _username = "..."; // Tambahan
  String _nomorRw = "...";  // Tambahan
  String _kodeUnik = "..."; // Tambahan 
  
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final result = await ApiService.getProfile();
    
    // Debugging: Cek apa isi result di terminal
    print("Profil Result: $result"); 

    if (mounted && result['success'] == true) {
      setState(() {
        final data = result['data'];
        _nama = data['nama_lengkap'] ?? "Tanpa Nama";
        _username = data['username'] ?? "user"; 
        
        // Pastikan key-nya sama dengan backend ('nomor_wilayah')
        _nomorRw = data['nomor_wilayah'] ?? "Wilayah -";
        _kodeUnik = data['kode_unik'] ?? "-";
      });
    }
  }

  void _handleLogout() {
    // 1. Panggil fungsi logout di service
    ApiService.logout();

    // 2. Tendang ke halaman Login (Hapus semua history navigasi agar tidak bisa back)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()), 
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6E6), // Warna Krem Background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40), // Jarak aman status bar
            const Text(
              "Profil Saya",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // --- KARTU PROFIL UTAMA ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                children: [
                  // Avatar Bulat Hitam (Sesuai Desain)
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  // Teks Nama & Role
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ...
                      Text(
                        _nama, // Nama Asli
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "@$_username", // Username Asli (contoh: @bambang123)
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        _nomorRw, // Nomor RW Asli (contoh: RW 009)
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      // Badge Terverifikasi
                      Row(
                        children: const [
                          Text("Terverifikasi", style: TextStyle(color: Colors.lightGreen, fontSize: 12)),
                          SizedBox(width: 5),
                          Icon(Icons.check_circle, color: Colors.lightGreen, size: 14),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- MENU PENGATURAN 1 ---
            _buildMenuCard([
              _buildMenuItem(Icons.lock_outline, "Ubah Kata Sandi"),
              const Divider(height: 1),
              _buildMenuItem(Icons.info_outline, "Ubah No. Handphone & Email"),
            ]),

            const SizedBox(height: 20),

            // --- MENU PENGATURAN 2 ---
            _buildMenuCard([
              _buildMenuItem(Icons.description_outlined, "Syarat & Ketentuan"),
              const Divider(height: 1),
              _buildMenuItem(Icons.help_outline, "Alamat/ Wilayah"),
            ]),

            const SizedBox(height: 20),

            // --- INFO & KODE UNIK ---
            _buildMenuCard([
              _buildMenuItem(Icons.info, "Informasi dan Dukungan"),
              const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text("Kode Unik: $_kodeUnik", style: const TextStyle(fontWeight: FontWeight.bold)), // Kode Asli
                ],
              ),
            ),
          ]),

            const SizedBox(height: 30),

            // --- TOMBOL LOGOUT ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2D55), // Warna Merah Pink sesuai desain
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Log Out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            
            const SizedBox(height: 30), // Spasi bawah
          ],
        ),
      ),
    );
  }

  // Widget Pembantu untuk Kartu Menu Putih
  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: children),
    );
  }

  // Widget Pembantu untuk Item Menu
  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        // Logika pindah halaman nanti di sini
      },
    );
  }
}