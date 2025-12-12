import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Pastikan ada package ini
import '../../services/api_service.dart';
import '../../widgets/logo_widget.dart';
import 'form_pengajuan_screen.dart';
import 'riwayat_pengajuan_screen.dart';
import 'lengkapi_profil_screen.dart'; // Pastikan import ini benar

class WargaDashboard extends StatefulWidget {
  const WargaDashboard({super.key});

  @override
  State<WargaDashboard> createState() => _WargaDashboardState();
}

class _WargaDashboardState extends State<WargaDashboard> {
  // Variabel Tampilan
  String _nama = "Memuat...";
  String _nik = "................";
  String _alamat = "Memuat...";
  String _rawStatus = "pending"; // Ini status mentah dari database (pending/verified/rejected)

  // Variabel Data Sensus (Untuk Cek Kelengkapan)
  bool _isDataLengkap = true; 

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fungsi Fetch Data
  Future<void> _fetchData() async {
    final profil = await ApiService.getMe();
    
    if (mounted && profil != null) {
      // 1. Cek apakah kolom wajib sudah terisi?
      bool lengkap = true;
      if (profil['jenis_kelamin'] == null ||
          profil['agama'] == null ||
          profil['pekerjaan'] == null ||
          profil['status_perkawinan'] == null) {
        lengkap = false;
      }

      setState(() {
        _nama = profil['nama_lengkap'] ?? "Warga";
        _nik = profil['nik'] ?? "-";
        _alamat = profil['alamat'] ?? "-";
        _rawStatus = profil['status'] ?? "pending"; // Ambil status verifikasi
        _isDataLengkap = lengkap;
      });
    }
  }

  // --- LOGIC NAVIGASI KE FORM LENGKAPI DATA ---
  void _goToLengkapiProfil() async {
    // 1. AWAIT: Tunggu sampai halaman formulir ditutup
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        // PERHATIAN: Hapus 'const' di sini karena kita kirim variabel '_rawStatus'
        builder: (context) => LengkapiProfilScreen(
          statusVerifikasi: _rawStatus, // <--- INI PERBAIKAN UTAMANYA
        ),
      ),
    );

    // 2. CHECK: Jika formulir mengirim sinyal 'true' (berhasil simpan)
    if (result == true) {
      print("Data tersimpan, refresh dashboard...");
      _fetchData(); // Refresh data dashboard
    }
  }

  // --- HELPER STATUS (Warna & Icon) ---
  Color _getStatusColor() {
    final statusBersih = _rawStatus.toString().toLowerCase().trim();
    if (statusBersih == 'verified' || statusBersih == 'disetujui' || statusBersih == '1') {
      return Colors.green;
    } else if (statusBersih == 'rejected' || statusBersih == 'ditolak') {
      return Colors.red;
    } else {
      return Colors.orange;
    }
  }

  String _getStatusText() {
    final statusBersih = _rawStatus.toString().toLowerCase().trim();
    if (statusBersih == 'verified' || statusBersih == 'disetujui' || statusBersih == '1') {
      return "Terverifikasi";
    } else if (statusBersih == 'rejected' || statusBersih == 'ditolak') {
      return "Ditolak / Perbaiki";
    } else {
      return "Menunggu Verifikasi";
    }
  }

  IconData _getStatusIcon() {
    final statusBersih = _rawStatus.toString().toLowerCase().trim();
    if (statusBersih == 'verified' || statusBersih == 'disetujui' || statusBersih == '1') {
      return Icons.check_circle;
    } else if (statusBersih == 'rejected' || statusBersih == 'ditolak') {
      return Icons.cancel;
    } else {
      return Icons.access_time_filled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();
    final statusIcon = _getStatusIcon();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6E6),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. HEADER LOGO ---
                const Center(
                  child: LogoWidget(height: 150, width: 150),
                ),

                // --- 2. SAPAAN ---
                Text(
                  "Halo, $_nama!",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // --- NOTIFIKASI JIKA DATA BELUM LENGKAP ---
                if (!_isDataLengkap) 
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: InkWell(
                      onTap: _goToLengkapiProfil,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 30),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Profil Belum Lengkap!",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                                  ),
                                  Text(
                                    "Ketuk di sini untuk melengkapi data Agama, Pekerjaan, dll.",
                                    style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.orange),
                          ],
                        ),
                      ),
                    ),
                  ),

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
                            // Tombol Detail/Edit Data
                            ElevatedButton(
                              onPressed: _goToLengkapiProfil, 
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF9FA8DA),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                minimumSize: const Size(0, 30),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              child: Text(_isDataLengkap ? "Lihat Detail" : "Lengkapi", style: const TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      
                      // Status Bar di Bawah Kartu
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Alamat Domisili:", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text(
                                    _alamat, 
                                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    maxLines: 2, overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1), 
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusColor.withOpacity(0.5))
                              ),
                              child: Row(
                                children: [
                                  Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 6),
                                  Icon(statusIcon, color: statusColor, size: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // --- 4. MENU GRID ---
                Row(
                  children: [
                    Expanded(
                      child: _buildMenuButton(
                        icon: Icons.edit_document, 
                        label: "Ajukan Perubahan NIK/KK", 
                        onTap: () {
                          if (!_isDataLengkap) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text("Harap lengkapi profil terlebih dahulu!"))
                             );
                             return;
                          }
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const FormPengajuanScreen()));
                        },
                        isLocked: !_isDataLengkap, 
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildMenuButton(
                        icon: Icons.receipt_long,
                        label: "Riwayat Pengajuan",
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatPengajuanScreen()));
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon, 
    required String label, 
    required VoidCallback onTap,
    bool isLocked = false
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey : const Color(0xFF6B8E78), 
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isLocked ? Icons.lock : icon, color: Colors.white, size: 30),
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