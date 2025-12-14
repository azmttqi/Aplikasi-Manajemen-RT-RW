import 'package:flutter/material.dart';
import 'dart:async'; // Untuk Timer (Debounce search)
import '../../services/api_service.dart'; // Import Service API
import 'DetailAkunPage.dart'; 
import '../../widgets/logo_widget.dart'; // Import Logo Widget

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
          idUser: data['id_pengguna'] ?? 0,
          // Pastikan kirim status verifikasi yang benar
          isVerified: (data['status_verifikasi_id'] == 2),
          
          nik: data['email'] ?? '-',
          nama: data['nama_ketua_rt'] ?? data['username'] ?? 'Belum ada Ketua',
          rt: data['nomor_rt'] ?? '-',
          judulHalaman: "Detail Akun RT",
          labelInfo: "Email Ketua RT",
        ),
      ),
    ).then((_) {
      // --- BARIS AJAIB INI ---
      // Saat kembali dari halaman detail, panggil data ulang dari backend
      print("Kembali dari detail, refresh data...");
      _fetchData(); 
    });
  }

@override
  Widget build(BuildContext context) {
    // Definisi warna biar seragam (bisa ditaruh di atas juga)
    const Color backgroundColor = Color(0xFFF8F2E5); 

    return Material(
      color: backgroundColor, // Background utama krem
      child: Column(
        children: [
          // --- HEADER (PERBAIKAN WARNA) ---
          const Center(
            child: LogoWidget(
              height: 180, 
                 width: 180,
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
  Widget _buildRtCard(Map<String, dynamic> data, int index) {

    // --- TAMBAHKAN DEBUGGING INI ---
    print("DEBUG DATA RT $index: ID User=${data['id_pengguna']}, Status=${data['status_verifikasi_id']}");
    
    // 1. Ambil Data
    final String nomorRt = data['nomor_rt'] ?? data['kode_rt'] ?? '-';
    final String namaKetua = data['nama_ketua_rt'] ?? data['username'] ?? 'Belum ada Ketua';
    
    // 2. CEK STATUS YANG BENAR (Berdasarkan ID Verifikasi dari Database)
    // Asumsi di database: 1 = Pending, 2 = Disetujui/Aktif, 3 = Ditolak
    // (Sesuaikan dengan isi tabel status_verifikasi Anda)
    final int statusId = data['status_verifikasi_id'] ?? 1; // Default 1 (Pending)
    
    final bool isVerified = (statusId == 2); // Hanya aktif jika ID-nya 2
    final bool hasUser = (namaKetua != 'Belum ada Ketua'); // Cek apakah ada user yg daftar

    // Tentukan Teks & Warna Status
    String statusText = "Kosong";
    Color statusColor = Colors.grey;
    Color statusBgColor = Colors.grey[200]!;

    if (hasUser) {
      if (isVerified) {
        statusText = "Aktif";
        statusColor = Colors.green[800]!;
        statusBgColor = Colors.green[100]!;
      } else {
        statusText = "Pending"; // Ini yang akan muncul jika belum diverifikasi
        statusColor = Colors.orange[800]!;
        statusBgColor = Colors.orange[100]!;
      }
    }

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
              // Icon Rumah
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isVerified ? Colors.blue[50] : Colors.orange[50], // Biru jika aktif, Orange jika pending
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.home_work,
                  color: isVerified ? Colors.blue : Colors.orange,
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
                      hasUser ? namaKetua : "Belum ada pendaftar",
                      style: TextStyle(
                        fontSize: 14,
                        color: hasUser ? Colors.black87 : Colors.grey,
                        fontWeight: hasUser ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              // Chip Status (Pojok Kanan)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
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