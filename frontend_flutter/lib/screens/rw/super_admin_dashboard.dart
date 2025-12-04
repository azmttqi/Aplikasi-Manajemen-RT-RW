import 'package:flutter/material.dart';
import '../../services/api_service.dart'; // Sesuaikan path jika perlu
import 'DetailAkunPage.dart'; // Sesuaikan path jika perlu
import 'DetailStatistikWarga.dart';
import 'account_search_screen.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // Fungsi mengambil data dari Backend
  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Panggil API (Pastikan fungsi ini ada di ApiService)
      final result = await ApiService.getDashboardStats();

      if (mounted) { // Cek apakah layar masih aktif
        setState(() {
          _isLoading = false;
          if (result['success'] == true) {
            _dashboardData = result['data'];
          } else {
            _errorMessage = result['message'] ?? "Gagal mengambil data";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Terjadi kesalahan koneksi: $e";
        });
      }
    }
  }

void _navigateToDetail(String title, String value) {
    
    // SKENARIO 1: Jika klik "Jumlah Warga" -> Ke Halaman Statistik Gender
    if (title == 'Jumlah Warga') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailStatistikWarga(
            total: value,
            // Ambil data detail dari _dashboardData (pastikan backend sudah kirim)
            laki: _dashboardData?['total_laki']?.toString() ?? '0',
            perempuan: _dashboardData?['total_perempuan']?.toString() ?? '0',
          ),
        ),
      );
    } 
    
    // SKENARIO 2: Jika klik "Jumlah RT" -> Ke Halaman List RT (Pencarian)
    else if (title == 'Jumlah RT') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AccountSearchScreen(), // Halaman List RT yang tadi kita fix
        ),
      );
    }
    
    // SKENARIO 3: Lainnya (misal KK) -> Tampilkan Detail Sederhana (Opsional)
    else {
      // Bisa ke detail page biasa atau biarkan kosong
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Detail belum tersedia"))
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    const Color softBackgroundColor = Color(0xFFFAF6E6);

    return Material(
      color: softBackgroundColor,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Tampilkan Loading
          : _errorMessage != null
              ? Center( // Tampilkan Error & Tombol Retry
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 10),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchDashboardData,
                        child: const Text("Coba Lagi"),
                      )
                    ],
                  ),
                )
              : RefreshIndicator( // Fitur Tarik ke Bawah untuk Refresh
                  onRefresh: _fetchDashboardData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 100.0, top: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Header ---
                          Center(
                            child: Column(
                              children: [
                                const Icon(Icons.home_work, size: 60, color: Color(0xFF4CAF50)),
                                const SizedBox(height: 5),
                                Text('Manajemen RT/RW', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                                const Text('Membangun Komunitas Cerdas', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          const Text('Dashboard Super Admin', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 4),
                          const Text('Data Realtime Wilayah', style: TextStyle(fontSize: 16, color: Color(0xFFD36F00), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 20),

                          // --- KARTU DATA (REAL COUNT) ---
                          // Kita ambil data dari _dashboardData, jika null pakai '0'
                          _buildDataCard(
                            title: 'Jumlah Warga',
                            value: _dashboardData?['total_warga']?.toString() ?? '0',
                          ),
                          const SizedBox(height: 15),
                          
                          _buildDataCard(
                            title: 'Jumlah Kartu Keluarga',
                            value: _dashboardData?['total_kk']?.toString() ?? '0',
                          ),
                          const SizedBox(height: 15),
                          
                          _buildDataCard(
                            title: 'Jumlah RT',
                            value: _dashboardData?['total_rt']?.toString() ?? '0',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildDataCard({required String title, required String value}) {
    return InkWell(
      onTap: () => _navigateToDetail(title, value),
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black54)),
              const SizedBox(height: 10),
              // Angka Besar
              Text(
                value, 
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}