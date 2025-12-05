import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'verify_detail_screen.dart'; // Import Detail Screen

class VerifyListScreen extends StatefulWidget {
  const VerifyListScreen({super.key});

  @override
  State<VerifyListScreen> createState() => _VerifyListScreenState();
}

class _VerifyListScreenState extends State<VerifyListScreen> {
  String _selectedFilter = "Menunggu"; // Default tab
  List<dynamic> _wargaList = []; // Data mentah dari API
  bool _isLoading = true;
  String _nomorRt = "";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() => _isLoading = true);
    
    // 1. Ambil Profil (untuk judul)
    final profil = await ApiService.getMe();
    if (mounted && profil != null) {
      setState(() {
        _nomorRt = profil['nomor_wilayah'] ?? "";
      });
    }

    // 2. Ambil SEMUA data warga
    final list = await ApiService.getWargaList(query: '');
    
    if (mounted) {
      setState(() {
        _wargaList = list;
        _isLoading = false;
      });
    }
  }

  // === 🧠 LOGIKA FILTER (PENTING) ===
  List<dynamic> get _filteredList {
    // 1. Jika tab "Semua", tampilkan semua
    if (_selectedFilter == "Semua") return _wargaList;
    
    // 2. Tentukan target status berdasarkan Tab
    String targetStatus = 'pending'; 
    if (_selectedFilter == "Disetujui") targetStatus = 'disetujui';
    if (_selectedFilter == "Ditolak") targetStatus = 'ditolak';
    // Tab "Menunggu" targetnya 'pending'

    // 3. Lakukan penyaringan
    return _wargaList.where((w) {
      // Ambil status dari data, ubah ke lowercase biar aman
      String statusWarga = (w['status_verifikasi'] ?? 'pending').toString().toLowerCase();
      
      return statusWarga == targetStatus;
    }).toList();
  }

  // Fungsi Verifikasi Cepat (dari tombol list)
  void _prosesVerifikasi(int idWarga, String status) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Memproses...")));

    bool sukses = await ApiService.updateStatusWarga(idWarga, status);

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (sukses) {
        _fetchData(); // Refresh data agar pindah tab otomatis
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Berhasil diubah ke $status"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal update status"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // --- HEADER ---
            Center(
              child: Column(
                children: [
                  const Icon(Icons.home_work_outlined, size: 50, color: Colors.green),
                  const Text("Manajemen\nRT/RW", textAlign: TextAlign.center, 
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, height: 1.2)),
                  const SizedBox(height: 20),
                  Text(
                    "Verifikasi Akun Warga Baru - $_nomorRt",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // --- TAB FILTER ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterTab("Semua"),
                  _buildFilterTab("Menunggu"),
                  _buildFilterTab("Disetujui"),
                  _buildFilterTab("Ditolak"),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // --- LIST DATA ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredList.isEmpty 
                      ? Center(child: Text("Tidak ada data di tab '$_selectedFilter'")) 
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: _filteredList.length,
                          // PENTING: Gunakan _filteredList, BUKAN _wargaList
                          itemBuilder: (context, index) {
                            final data = _filteredList[index];
                            return _buildWargaCard(data);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    bool isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.orange : Colors.white, // Aktif = Orange, Mati = Putih
          borderRadius: BorderRadius.circular(20), // Biar bulat kayak 'Pill'
          border: Border.all(color: isActive ? Colors.orange : Colors.grey.shade300),
          boxShadow: [
             if(!isActive) BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 3, offset: const Offset(0, 1))
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildWargaCard(Map<String, dynamic> data) {
    final int idWarga = data['id_warga'] ?? 0;
    String nama = data['nama_lengkap'] ?? "Warga Tanpa Nama";
    String nik = data['nik'] ?? "0000000000000000";
    String maskedNik = nik.length > 6 ? "${nik.substring(0, 6)}xxxxxxxxxx" : nik;
    
    // Cek status data ini
    String status = (data['status_verifikasi'] ?? 'pending').toString().toLowerCase();
    bool isPending = status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Atas: Nama & Badge Status Kecil
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nama Warga", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  Text(nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              // Badge Status di pojok kanan
              if (!isPending) 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: status == 'disetujui' ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: status == 'disetujui' ? Colors.green : Colors.red, width: 0.5),
                  ),
                  child: Text(
                    status.toUpperCase(), 
                    style: TextStyle(fontSize: 10, color: status == 'disetujui' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)
                  ),
                )
            ],
          ),
          
          const SizedBox(height: 4),
          Text("NIK: $maskedNik", style: const TextStyle(fontSize: 12, color: Colors.black)),
          
          const SizedBox(height: 15),
          
          // Row Tombol Aksi
          Row(
            children: [
              // HANYA TAMPILKAN TOMBOL TERIMA/TOLAK JIKA STATUS PENDING
              if (isPending) ...[
                _actionButton("Disetujui", Colors.blue, () => _prosesVerifikasi(idWarga, "disetujui")),
                const SizedBox(width: 8),
                _actionButton("Tolak", Colors.red, () => _prosesVerifikasi(idWarga, "ditolak")),
                const SizedBox(width: 8),
              ],
              
              // Tombol Detail Selalu Ada
              Expanded(
                child: SizedBox(
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Buka Detail
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VerifyDetailScreen(data: data)),
                      );
                      // Refresh jika ada perubahan
                      if (result == true) _fetchData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC5CAE9), 
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text("Detail", style: TextStyle(fontSize: 11, color: Colors.black)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: SizedBox(
        height: 35,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(backgroundColor: color, padding: EdgeInsets.zero),
          child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white)),
        ),
      ),
    );
  }
}