import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'form_pengajuan_screen.dart';
import 'riwayat_pengajuan_screen.dart';
import '../../widgets/logo_widget.dart';

class WargaDashboard extends StatefulWidget {
  const WargaDashboard({super.key});

  @override
  State<WargaDashboard> createState() => _WargaDashboardState();
}

class _WargaDashboardState extends State<WargaDashboard> {
  String _nama = "Memuat...";
  String _nik = "................";
  String _alamat = "Memuat...";
  String _rawStatus = "pending"; 

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Ubah fungsi ini agar me-return Future (Syarat RefreshIndicator)
  Future<void> _fetchData() async {
    final profil = await ApiService.getMe();
    if (mounted && profil != null) {
      setState(() {
        _nama = profil['nama_lengkap'] ?? "Warga";
        _nik = profil['nik'] ?? "-"; 
        _alamat = profil['alamat'] ?? "-";
        
        // Simpan apa adanya dulu untuk dicek
        _rawStatus = profil['status'].toString(); 
      });
    }
  }

  // --- HELPER STATUS (Sama seperti sebelumnya) ---
// 1. Logic Warna
  Color _getStatusColor() {
    final statusBersih = _rawStatus.toString().toLowerCase().trim();

    // Tambahkan 'disetujui' di sini
    if (statusBersih == 'verified' || statusBersih == 'disetujui' || statusBersih == '1') {
      return Colors.green;
    } 
    // Tambahkan 'ditolak' di sini (jaga-jaga)
    else if (statusBersih == 'rejected' || statusBersih == 'ditolak' || statusBersih == '2') {
      return Colors.red;
    } 
    else {
      return Colors.orange; // Default (pending/diajukan)
    }
  }

  // 2. Logic Teks Tampilan
  String _getStatusText() {
    final statusBersih = _rawStatus.toString().toLowerCase().trim();

    if (statusBersih == 'verified' || statusBersih == 'disetujui' || statusBersih == '1') {
      return "Terverifikasi";
    } 
    else if (statusBersih == 'rejected' || statusBersih == 'ditolak') {
      return "Ditolak / Perbaiki";
    } 
    else {
      return "Menunggu Verifikasi";
    }
  }

  // 3. Logic Ikon
  IconData _getStatusIcon() {
    final statusBersih = _rawStatus.toString().toLowerCase().trim();

    if (statusBersih == 'verified' || statusBersih == 'disetujui' || statusBersih == '1') {
      return Icons.check_circle;
    } 
    else if (statusBersih == 'rejected' || statusBersih == 'ditolak') {
      return Icons.cancel;
    } 
    else {
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
      // 1. RefreshIndicator membungkus SingleChildScrollView
      child: RefreshIndicator(
        onRefresh: _fetchData, 
        child: SingleChildScrollView(
          // 2. [PENTING!] Tambahkan baris ini agar bisa ditarik walau konten sedikit
          physics: const AlwaysScrollableScrollPhysics(), 
          
          padding: const EdgeInsets.all(20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. HEADER LOGO ---
                const Center(
                  child: LogoWidget(
                    height: 180, 
                    width: 180,
                  ),
                ),

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
                      
                      // STATUS (Bagian ini akan berubah otomatis setelah refresh)
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
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
                                  Text(
                                    statusText, 
                                    style: TextStyle(
                                      color: statusColor, 
                                      fontSize: 11, 
                                      fontWeight: FontWeight.bold
                                    )
                                  ),
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
                        icon: Icons.edit,
                        label: "Ajukan Perubahan Data",
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const FormPengajuanScreen()));
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildMenuButton(
                        icon: Icons.receipt_long,
                        label: "Riwayat Pengajuan Data",
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatPengajuanScreen()));
                        },
                      ),
                    ),
                  ],
                ),
                
                // Tambahan ruang di bawah agar scroll lebih enak
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({required IconData icon, required String label, required VoidCallback onTap}) {
    // (Kode tombol sama seperti sebelumnya)
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF6B8E78),
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