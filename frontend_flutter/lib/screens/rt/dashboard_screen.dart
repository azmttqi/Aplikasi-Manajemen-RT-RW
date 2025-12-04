import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart'; // Pastikan path ini benar sesuai project Anda
import '../../services/api_service.dart'; // Import API Service

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int navIndex = 0;
  
  // State untuk data dashboard
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Panggil data saat halaman pertama kali dibuka
  }

  // Fungsi mengambil data dari Backend
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Panggil API (Backend otomatis tahu ini RT berdasarkan Token)
      final result = await ApiService.getDashboardStats();

      if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E5),
      appBar: AppBar(
        title: const Text('Dashboard Admin RT', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      
      // LOGIKA TAMPILAN BODY
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // 1. Loading
          : _errorMessage != null
              ? Center( // 2. Error & Retry
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 10),
                      Text(_errorMessage!),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchData,
                        child: const Text("Coba Lagi"),
                      )
                    ],
                  ),
                )
              : RefreshIndicator( // 3. Data Asli (Bisa di-refresh)
                  onRefresh: _fetchData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            "Statistik Lingkungan",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          
                          // KARTU 1: JUMLAH WARGA
                          cardInfo(
                            'Jumlah Warga', 
                            _dashboardData?['total_warga']?.toString() ?? '0',
                            Icons.people,
                            Colors.blue
                          ),
                          
                          // KARTU 2: JUMLAH KK
                          cardInfo(
                            'Jumlah KK', 
                            _dashboardData?['total_kk']?.toString() ?? '0',
                            Icons.folder_shared,
                            Colors.orange
                          ),

                          // (Opsional) Info Tambahan
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              "Data ini diambil secara realtime dari database.",
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      
      // Navigasi Bawah Tetap Sama
      bottomNavigationBar: BottomNav(
        currentIndex: navIndex,
        onTap: (i) {
          setState(() => navIndex = i);
          // Pastikan route '/search' dan '/profile' sudah didaftarkan di main.dart
          if (i == 2) Navigator.pushNamed(context, '/search');
          if (i == 3) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }

  Widget cardInfo(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
        ],
      ),
    );
  }
}