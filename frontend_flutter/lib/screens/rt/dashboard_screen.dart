import 'package:flutter/material.dart';
import '../../services/api_service.dart'; 
import '../../widgets/logo_widget.dart';
import 'daftar_kk_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- SISTEM DATA TETAP ---
  bool _isLoading = true;
  Map<String, dynamic>? _statsData; 
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
      final result = await ApiService.getStatistikWargaRT();
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (result != null) {
            _statsData = result;
          } else {
            _errorMessage = "Gagal mengambil data statistik";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Terjadi kesalahan koneksi.";
        });
      }
    }
  }

  // === POPUP ANALITIK PRESISI (GAYA RW + DRILL-DOWN) ===
  void _showWargaAnalytics(BuildContext context) {
    if (_statsData == null) return;
    String currentView = "main"; 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              builder: (_, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(25),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Center(
                        child: Container(
                          width: 50, height: 5,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      
                      // HEADER POPUP (Judul Berubah saat Drill-down)
                      Row(
                        children: [
                          if (currentView != "main") 
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, size: 20),
                              onPressed: () => setModalState(() => currentView = "main"),
                            ),
                          Text(
                            currentView == "main" ? "Analisis Warga" : 
                            currentView == "pria" ? "Rincian Usia Pria" : "Rincian Usia Wanita",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 15),

                      // VIEW 1: UTAMA (GENDER & TOTAL USIA)
                      if (currentView == "main") ...[
                        _rowInfoInteractive("Laki-laki", "${_statsData!['total_pria']}", Icons.male, Colors.blue, 
                          () => setModalState(() => currentView = "pria")),
                        _rowInfoInteractive("Perempuan", "${_statsData!['total_wanita']}", Icons.female, Colors.pink, 
                          () => setModalState(() => currentView = "wanita")),
                        
                        const SizedBox(height: 25),
                        const Text("Kategori Usia Keseluruhan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 15),
                        
                        // PERBAIKAN: Petakan 'total_lansia' ke kunci 'lansia'
                        _ageRowPrecise({
                          'lansia': _statsData!['total_lansia'] ?? 0,
                          'dewasa': _statsData!['total_dewasa'] ?? 0,
                          'remaja': _statsData!['total_remaja'] ?? 0,
                          'anak': _statsData!['total_anak'] ?? 0,
                        }),
                      ],

                      // VIEW DRILL-DOWN PRIA
                      if (currentView == "pria") ...[
                        _ageRowPrecise({
                          'lansia': _statsData!['pria_lansia'] ?? 0,
                          'dewasa': _statsData!['pria_dewasa'] ?? 0,
                          'remaja': _statsData!['pria_remaja'] ?? 0,
                          'anak': _statsData!['pria_anak'] ?? 0,
                        }),
                        const SizedBox(height: 20),
                        const Center(child: Text("*Data usia khusus warga Laki-laki", style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic))),
                      ],

                      // VIEW DRILL-DOWN WANITA
                      if (currentView == "wanita") ...[
                        _ageRowPrecise({
                          'lansia': _statsData!['wanita_lansia'] ?? 0,
                          'dewasa': _statsData!['wanita_dewasa'] ?? 0,
                          'remaja': _statsData!['wanita_remaja'] ?? 0,
                          'anak': _statsData!['wanita_anak'] ?? 0,
                        }),
                        const SizedBox(height: 20),
                        const Center(child: Text("*Data usia khusus warga Perempuan", style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic))),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // --- POPUP KK (BISA DIKLIK) ---
  void _showKkDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text("Informasi Keluarga", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              _rowInfoSimple("Total Kartu Keluarga", "${_statsData?['total_kk'] ?? 0} KK", Icons.folder_shared, Colors.green),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); 
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DaftarKkScreen()));
                  },
                  icon: const Icon(Icons.list),
                  label: const Text("Lihat Daftar KK"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8F2E5),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6E6), // Tema RW
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Center(child: LogoWidget(height: 120, width: 120)),
                        const SizedBox(height: 20),
                        const Text('Dashboard Admin RT', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 5),
                        const Text('Data Statistik Lingkungan RT', style: TextStyle(fontSize: 16, color: Color(0xFFD36F00), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 25),
                        
                        _buildStatCard(
                          'Jumlah Warga', 
                          (_statsData?['total_warga_riil'] ?? '0').toString(),
                          Icons.people,
                          Colors.blue,
                          () => _showWargaAnalytics(context),
                        ),
                        const SizedBox(height: 15),
                        _buildStatCard(
                          'Jumlah KK', 
                          (_statsData?['total_kk'] ?? '0').toString(),
                          Icons.folder_shared,
                          Colors.green,
                          () => _showKkDetail(context),
                        ),  
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
    );
  }

  // --- WIDGET HELPER PRESISI ---

  Widget _buildStatCard(String title, String count, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20.0), 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded( // Anti-overflow fix
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(count, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowInfoInteractive(String label, String value, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 15),
            Text(label, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _rowInfoSimple(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 15),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  // BARIS USIA HORIZONTAL (Presisi sesuai image_bdf32a.png)
  Widget _ageRowPrecise(dynamic data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ageTilePrecise("Lansia", data?['lansia'], Colors.orange),
        _ageTilePrecise("Dewasa", data?['dewasa'], Colors.teal),
        _ageTilePrecise("Remaja", data?['remaja'], Colors.indigo),
        _ageTilePrecise("Anak", data?['anak'], Colors.redAccent),
      ],
    );
  }

  Widget _ageTilePrecise(String label, dynamic count, Color color) {
    return Expanded( // Membagi rata ruang 4 kotak
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text("${count ?? 0}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}