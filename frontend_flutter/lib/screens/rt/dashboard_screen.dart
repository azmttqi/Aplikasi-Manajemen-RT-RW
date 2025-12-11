import 'package:flutter/material.dart';
import '../../services/api_service.dart'; 
import '../../widgets/logo_widget.dart'; // Import Logo Widget

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData(); 
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
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
      backgroundColor: const Color(0xFFF8F2E5), // Background Cream
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 10),
                      Text(_errorMessage!),
                      ElevatedButton(onPressed: _fetchData, child: const Text("Coba Lagi"))
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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

                        const SizedBox(height: 0), 

                        // --- 2. JUDUL ---
                        const Text(
                          'Dashboard Admin RT',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Data Statistik Lingkungan',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // --- 3. KARTU STATISTIK ---
                        
                        // KARTU JUMLAH WARGA
                        cardInfo(
                          'Jumlah Warga', 
                          _dashboardData?['total_warga']?.toString() ?? '0',
                          Icons.people,
                          Colors.blue
                        ),
                        
                        // KARTU JUMLAH KK
                        cardInfo(
                          'Jumlah KK', 
                          _dashboardData?['total_kk']?.toString() ?? '0',
                          Icons.folder_shared,
                          Colors.green 
                        ),

                        // KARTU PENDING (Tetap saya biarkan sebagai info statistik)
                        cardInfo(
                          'Menunggu Verifikasi', 
                          _dashboardData?['pending']?.toString() ?? '0',
                          Icons.notifications_active,
                          Colors.orange
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }

  // Widget Kartu Statistik
  Widget cardInfo(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15), 
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15), 
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
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 36),
          ),
        ],
      ),
    );
  }
}