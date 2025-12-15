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
      // DEBUG: Cek di console apakah fungsi ini jalan
      print("Memulai ambil data dengan query: '$query'");

      // Panggil API (Pastikan endpoint ini mengembalikan List RT)
      final result = await ApiService.getWargaList(query: query);

      // DEBUG: Cek hasil mentah dari API di console
      print("Hasil API: $result");

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
        // DEBUG: Lihat errornya apa
        print("Error fetch data: $e");
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
  void _navigateToDetail(Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailAkunPage(
          idUser: data['id_pengguna'] ?? 0,
          // Cek status verifikasi (Asumsi ID 2 = Disetujui)
          isVerified: (data['status_verifikasi_id'] == 2),

          nik: data['email'] ?? '-',
          nama: data['nama_ketua_rt'] ??
              data['username'] ??
              'Belum ada Ketua',
          rt: (data['nomor_rt'] ?? '-').toString(),
          judulHalaman: "Detail Akun RT",
          labelInfo: "Email Ketua RT",
        ),
      ),
    ).then((_) {
      // Saat kembali dari halaman detail, refresh data biar update statusnya
      print("Kembali dari detail, refresh data...");
      _fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFF8F2E5);

    return Material(
      color: backgroundColor,
      child: Column(
        children: [
          // --- HEADER LOGO ---
          const Padding(
            padding: EdgeInsets.only(top: 40.0, bottom: 20.0),
            child: Center(
              child: LogoWidget(
                height: 120, // Ukuran disesuaikan
                width: 120,
              ),
            ),
          ),

          // --- JUDUL & SEARCH BAR ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 10.0),
                  child: Text('Data Ketua RT',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- LIST DATA DARI API ---
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage.isNotEmpty
                          ? Center(
                              child: Text(_errorMessage,
                                  style: const TextStyle(color: Colors.red)))
                          : _dataList.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.folder_off,
                                          size: 50, color: Colors.grey),
                                      SizedBox(height: 10),
                                      Text("Belum ada data RT"),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
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
    
    // 1. Ambil Data & AMANKAN TIPE DATA (PENTING!)
    // Pakai .toString() untuk jaga-jaga kalau backend kirim Angka
    final String nomorRt = (data['nomor_rt'] ?? data['kode_rt'] ?? '-').toString();
    final String namaKetua = data['nama_ketua_rt'] ?? data['username'] ?? 'Belum ada Ketua';

    // 2. LOGIKA STATUS
    final int statusId = data['status_verifikasi_id'] ?? 1; // Default 1 (Pending)
    final bool isVerified = (statusId == 2); 
    final bool hasUser = (namaKetua != 'Belum ada Ketua');

    // Tentukan Warna Status
    String statusText = "Kosong";
    Color statusColor = Colors.grey;
    Color statusBgColor = Colors.grey[200]!;

    if (hasUser) {
      if (isVerified) {
        statusText = "Aktif";
        statusColor = Colors.green[800]!;
        statusBgColor = Colors.green[100]!;
      } else {
        statusText = "Pending";
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
              // Icon Rumah (Warna berubah sesuai status)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isVerified ? Colors.blue[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.home_work,
                  color: isVerified ? Colors.blue : Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),

              // Info Teks (RT & Nama)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "RT $nomorRt",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
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

              // Chip Status (Pojok Kanan - Aktif/Pending)
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