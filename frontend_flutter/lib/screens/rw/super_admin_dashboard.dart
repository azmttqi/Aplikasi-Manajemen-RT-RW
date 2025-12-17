import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'StatistikPerRtScreen.dart'; 
import '../../widgets/logo_widget.dart';
import '../../utils/global_keys.dart'; 

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

  Future<void> _fetchDashboardData() async {
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
          _errorMessage = "Gagal terhubung ke server.";
        });
      }
    }
  }

  void _onCardTap(String title) {
    if (title == 'Jumlah Warga') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const StatistikPerRtScreen(
            title: "Sebaran Warga per RT",
            dataType: "warga",
          ),
        ),
      );
    } else if (title == 'Jumlah Kartu Keluarga') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const StatistikPerRtScreen(
            title: "Sebaran KK per RT",
            dataType: "kk",
          ),
        ),
      );
    } else if (title == 'Jumlah RT') {
      // Pindah ke Tab "Data RT" (Index 1) menggunakan GlobalKey
      final state = mainScreenKey.currentState;
      if (state != null) {
        // Casting ke dynamic agar fungsi changeTab terdeteksi
        (state as dynamic).changeTab(1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFFAF6E6); 

    return Scaffold(
      backgroundColor: backgroundColor,
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
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchDashboardData,
                        child: const Text("Coba Lagi"),
                      )
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchDashboardData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const Center(
                            child: LogoWidget(height: 120, width: 120),
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            'Dashboard RW',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Data Statistik Lingkungan RW',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFD36F00),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 25),

                          _buildStatCard(
                            title: 'Jumlah Warga',
                            count: _dashboardData?['total_warga']?.toString() ?? '0',
                            icon: Icons.people,
                            color: Colors.blue,
                          ),

                          const SizedBox(height: 15),

                          _buildStatCard(
                            title: 'Jumlah Kartu Keluarga',
                            count: _dashboardData?['total_kk']?.toString() ?? '0',
                            icon: Icons.folder_shared, 
                            color: Colors.green,
                          ),

                          const SizedBox(height: 15),

                          _buildStatCard(
                            title: 'Jumlah RT',
                            count: _dashboardData?['total_rt']?.toString() ?? '0',
                            icon: Icons.home_work, 
                            color: Colors.orange,
                          ),
                          
                          const SizedBox(height: 100), 
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _onCardTap(title),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20.0), 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    count,
                    style: const TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1), 
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color, 
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}