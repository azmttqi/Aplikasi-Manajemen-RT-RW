import 'package:flutter/material.dart';
import '../../services/api_service.dart';
// import 'warga_detail_screen.dart'; // (Nanti buat file ini)

class WargaDashboard extends StatefulWidget {
  const WargaDashboard({super.key});

  @override
  State<WargaDashboard> createState() => _WargaDashboardState();
}

class _WargaDashboardState extends State<WargaDashboard> {
  String _nama = "Memuat...";
  String _nik = "................";
  String _status = "Memuat...";
  String _alamat = "Memuat...";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    // Ambil Profil Warga
    final profil = await ApiService.getMe();
    if (mounted && profil != null) {
      setState(() {
        _nama = profil['nama_lengkap'] ?? "Warga";
        // NIK dll harusnya diambil dari tabel warga, 
        // untuk sekarang kita pakai placeholder atau data profil jika ada
        _nik = profil['nik'] ?? "32145xxxxxxxxx"; 
        _alamat = profil['alamat'] ?? "Jalan Panghegar";
        _status = "Terverifikasi"; // Nanti ambil status asli
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6E6), // Background Cream
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. HEADER LOGO ---
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Icon(Icons.home_work_rounded, size: 50, color: Colors.green),
                    const SizedBox(height: 5),
                    Text('Manajemen RT/RW', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                    const Text('Membangun Komunitas Cerdas', style: TextStyle(fontSize: 10, color: Colors.orange)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- 2. SAPAAN ---
              Text(
                "Halo, $_nama!",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // --- 3. KARTU DATA SAYA ---
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))
                  ],
                ),
                child: Column(
                  children: [
                    // Bagian Atas Kartu
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Data Saya", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 5),
                              Text("NIK: $_nik", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Ke Halaman Detail Warga
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Detail Segera Hadir")));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9FA8DA),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              minimumSize: const Size(0, 30),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            ),
                            child: const Text("Lihat Detail", style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    
                    // Bagian Bawah Kartu
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("NIK: $_nik", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                              const Text("status verifikasi", style: TextStyle(fontSize: 10, color: Colors.grey)),
                              const SizedBox(height: 5),
                              Text("Alamat: $_alamat", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                            ],
                          ),
                          Row(
                            children: [
                              Text(_status, style: const TextStyle(color: Colors.lightGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 4),
                              const Icon(Icons.check_circle, color: Colors.lightGreen, size: 14),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // --- 4. MENU GRID (TOMBOL HIJAU BESAR) ---
              Row(
                children: [
                  // Tombol Ajukan Perubahan
                  Expanded(
                    child: _buildMenuButton(
                      icon: Icons.edit,
                      label: "Ajukan Perubahan Data",
                      onTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Edit Segera Hadir")));
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Tombol Riwayat
                  Expanded(
                    child: _buildMenuButton(
                      icon: Icons.receipt_long,
                      label: "Riwayat Pengajuan Data",
                      onTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Riwayat Segera Hadir")));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Tombol Hijau Besar
  Widget _buildMenuButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF6B8E78), // Warna Hijau Army sesuai desain
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}