// screens/rw/super_admin_dashboard.dart

import 'package:flutter/material.dart';
// Perbaikan path absolut untuk menghilangkan warning
import 'package:frontend_flutter/services/api_service.dart'; 
import 'package:frontend_flutter/widgets/custom_card.dart'; 
import 'detailAkunPage.dart'; 

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  bool isLoading = true;
  Map<String, dynamic>? SuperAdminDashboardData;
  String? errorMessage;

  @override 
  void initState() {
    super.initState();
    fetchSuperAdminDashboardData(); 
  }

  Future<void> fetchSuperAdminDashboardData() async {
    // 💡 Perbaikan: Menggunakan ApiService untuk menghilangkan warning kuning
    try {
        final result = await ApiService.getSuperAdminDashboard();
        // ... set state berdasarkan result
    } catch (e) {
        // ... handle error
    }
  }

  void _navigateToDetail(String title, String value) {
    // Navigasi lokal: push halaman detail
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailAkunPage(
          nik: '0000',      // Placeholder
          nama: title,      // Judul Kartu
          rt: value,        // Nilai Kartu
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color softBackgroundColor = Color(0xFFFAF6E6);

    // 🚀 Perbaikan BNAV: Menggunakan Material sebagai root.
    return Material( 
      color: softBackgroundColor,
      
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 100.0, top: 20.0), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Konten Dashboard (tetap sama) ---
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
              const Text('Data Terbatas', style: TextStyle(fontSize: 16, color: Color(0xFFD36F00), fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              
              _buildDataCard(title: 'Jumlah Warga', value: '125.000'),
              const SizedBox(height: 15),
              _buildDataCard(title: 'Jumlah Kartu Keluarga', value: '95.000'),
              const SizedBox(height: 15),
              _buildDataCard(title: 'Jumlah RT', value: '15'),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pembantu (InkWell berfungsi di dalam Material root)
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
              Text(value, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}