import 'package:flutter/material.dart';
import 'dart:async'; // Untuk Timer (Debounce search)
import '../../services/api_service.dart'; // Import Service API
import 'detailAkunPage.dart'; 

class AccountSearchScreen extends StatefulWidget {
  const AccountSearchScreen({super.key});

  @override
  State<AccountSearchScreen> createState() => _AccountSearchScreenState();
}

class _AccountSearchScreenState extends State<AccountSearchScreen> {
  // Controller Pencarian
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // State Data
  bool _isLoading = true;
  List<dynamic> _dataList = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData(); // Ambil data saat halaman dibuka
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Fungsi Panggil API
  Future<void> _fetchData({String query = ""}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Panggil API (Backend otomatis tahu ini RW, jadi yang dikirim daftar RT)
      final result = await ApiService.getWargaList(query: query);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _dataList = result; 
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Gagal mengambil data: $e";
        });
      }
    }
  }

  // Logic Pencarian (Tunggu user selesai ketik 500ms baru request)
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchData(query: query);
    });
  }

  // Navigasi ke Detail
  // Di dalam class _AccountSearchScreenState ...

  void _navigateToDetail(Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailAkunPage(
          // Kirim data yang sesuai
          nik: data['email'] ?? '-', // Tampilkan Email karena RT belum tentu punya NIK di list ini
          nama: data['nama_ketua_rt'] ?? 'Belum ada Ketua',
          
          // Pastikan mengambil 'nomor_rt' yang sudah kita perbaiki di backend
          rt: data['nomor_rt'] ?? '-', 
          
          // --- JUDUL YANG BENAR ---
          judulHalaman: "Detail Akun RT", 
        ),
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    // Definisi warna biar seragam (bisa ditaruh di atas juga)
    const Color backgroundColor = Color(0xFFFAF6E6); 

    return Material(
      color: backgroundColor, // Background utama krem
      child: Column(
        children: [
          // --- HEADER (PERBAIKAN WARNA) ---
          Container(
            color: backgroundColor, // <--- GANTI INI (Tadinya Colors.white)
            padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
            width: double.infinity,
            child: Column(
              children: [
                const Icon(Icons.home_work, color: Colors.green, size: 40), 
                const SizedBox(height: 5),
                const Text(
                  'Manajemen RT/RW', 
                  style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)
                ),
                const Text(
                  'Membangun Komunitas Cerdas', 
                  style: TextStyle(color: Colors.green, fontSize: 10)
                ),
              ],
            ),
          ),
          
          // --- JUDUL & SEARCH BAR ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
                  child: Text('Data Ketua RT', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),

                // Kolom Pencarian
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Cari Nomor RT atau Nama Ketua...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- LIST DATA DARI API ---
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage.isNotEmpty
                          ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                          : _dataList.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.folder_off, size: 50, color: Colors.grey),
                                      Text("Belum ada data RT"),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  itemCount: _dataList.length,
                                  itemBuilder: (context, index) {
                                    final item = _dataList[index];
                                    return _buildRtCard(item, index);
                                  },
                                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Widget Kartu RT
// Widget Kartu RT
  Widget _buildRtCard(Map<String, dynamic> data, int index) {
    
    // 1. Ambil Nomor RT (Coba 'nomor_rt', kalau null coba 'kode_rt')
    final String nomorRt = data['nomor_rt'] ?? data['kode_rt'] ?? '-';
    
    // 2. Ambil Nama Ketua
    // Backend mungkin mengirim 'nama_ketua_rt', 'username', atau 'nama_lengkap'
    final String namaKetua = data['nama_ketua_rt'] ?? 
                             data['username'] ?? 
                             data['nama_lengkap'] ?? 
                             'Belum ada Ketua';
    
    // 3. Cek Status (Aktif jika nama ketuanya ada dan valid)
    final bool isActive = (namaKetua != 'Belum ada Ketua' && namaKetua.isNotEmpty); 

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () => _navigateToDetail(data),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon Status
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isActive ? Colors.blue[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.home_work,
                  color: isActive ? Colors.blue : Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              
              // Info Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "RT $nomorRt",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isActive ? namaKetua : "Menunggu Registrasi...",
                      style: TextStyle(
                        fontSize: 14,
                        color: isActive ? Colors.black87 : Colors.red,
                        fontStyle: isActive ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              // Chip Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isActive ? "Aktif" : "Pending",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.green[800] : Colors.orange[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}