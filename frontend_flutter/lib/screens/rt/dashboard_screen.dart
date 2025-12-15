import 'package:flutter/material.dart';
import '../../services/api_service.dart'; 
import '../../widgets/logo_widget.dart';
import 'daftar_kk_screen.dart';

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

      // --- TAMBAHKAN KODE INI UNTUK MELIHAT ISI DATA DI CONSOLE ---
      print("CEK DATA API: $result"); 
      // -----------------------------------------------------------

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

  // --- FUNGSI UNTUK MENAMPILKAN POPUP GENDER ---
  void _showGenderDetail(BuildContext context) {
    // 1. Ambil dulu objek 'gender' dari data dashboard
    //    Jika null, kita anggap map kosong {}
    final genderData = _dashboardData?['gender'] ?? {};

    // 2. Ambil data 'laki' dan 'perempuan' dari dalam genderData
    final int laki = int.tryParse(genderData['laki']?.toString() ?? '0') ?? 0;
    final int perempuan = int.tryParse(genderData['perempuan']?.toString() ?? '0') ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50, height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const Text(
                "Statistik Gender",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text("Perbandingan jumlah warga berdasarkan jenis kelamin.", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 25),

              // Item Laki-laki
              _genderItem("Laki-laki", laki, Icons.male, Colors.blue),
              
              const SizedBox(height: 15),
              
              // Item Perempuan
              _genderItem("Perempuan", perempuan, Icons.female, Colors.pink),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Widget kecil untuk baris gender
  Widget _genderItem(String label, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // Background transparan sesuai warna
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 15),
              Text(
                label,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          Text(
            "$count Jiwa",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }

// --- FUNGSI UNTUK POPUP STATUS KK ---
  void _showKkDetail(BuildContext context) {
    // CERITANYA: Nanti minta backend kirim data ini di dalam objek 'kk_stats'
    // Saat ini kita pakai data 0 dulu atau simulasi
    // final kkStats = _dashboardData?['kk_stats'] ?? {}; 
    
    // SEMENTARA: Kita anggap saja datanya begini (Simulasi)
    // Nanti kalau API sudah update, ganti angka ini dengan data dari API
    final int wargaTetap = 1; 
    final int wargaKontrak = 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50, height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const Text(
                "Status Tempat Tinggal",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text("Klasifikasi KK berdasarkan kepemilikan rumah.", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 25),

              // Item Warga Tetap
              _genderItem("Milik Sendiri", wargaTetap, Icons.home, Colors.orange),
              
              const SizedBox(height: 15),
              
              // Item Kontrakan
              _genderItem("Kontrak / Sewa", wargaKontrak, Icons.business, Colors.purple),
              
              const SizedBox(height: 25),

              // Tombol Aksi Tambahan (Opsional)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // 1. Tutup Popup dulu
                    Navigator.pop(context); 
                    
                    // 2. Buka Halaman Daftar KK
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DaftarKkScreen()),
                    );
                  },
                  icon: const Icon(Icons.list),
                  label: const Text("Lihat Detail Daftar KK"),
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
      backgroundColor: const Color(0xFFF8F2E5), 
      
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
                        
                        const Center(child: LogoWidget(height: 180, width: 180)),
                        const SizedBox(height: 0), 

                        const Text('Dashboard Admin RT', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 5),
                        const Text('Data Statistik Lingkungan', style: TextStyle(fontSize: 16, color: Color(0xFFD36F00))),
                        
                        const SizedBox(height: 20),
                        
                        // --- KARTU JUMLAH WARGA ---
                        cardInfo(
                          'Jumlah Warga', 
                          _dashboardData?['total_warga']?.toString() ?? '0',
                          Icons.people,
                          Colors.blue,
                          () {
                            // SAAT DIKLIK, PANGGIL FUNGSI POPUP GENDER
                            _showGenderDetail(context);
                          },
                        ),
                        
                        // --- KARTU JUMLAH KK ---
                        cardInfo(
                          'Jumlah KK', 
                          _dashboardData?['total_kk']?.toString() ?? '0',
                          Icons.folder_shared,
                          Colors.green,
                          () {
                            // PANGGIL FUNGSI INI
                            _showKkDetail(context);
                          },
                        ),  
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget cardInfo(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15), 
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 3)),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(value, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
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
          ),
        ),
      ),
    );
  }
}