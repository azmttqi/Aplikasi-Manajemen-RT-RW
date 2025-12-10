import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = true; // Default Loading biar gak kaget

  @override
  void initState() {
    super.initState();
    // PANGGIL DATA OTOMATIS SAAT HALAMAN DIBUKA
    _searchWarga(""); 
  }

  // Fungsi Pencarian
  void _searchWarga(String query) async {
    setState(() => _isLoading = true);

    // Panggil API (Kirim query kosong "" artinya ambil semua)
    final results = await ApiService.getWargaList(query: query);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Data Warga", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Hilangkan back button jika di nav bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // KOLOM PENCARIAN
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari Nama Warga...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                // Opsional: Cari otomatis saat mengetik (Live Search)
                _searchWarga(value);
              },
            ),
            const SizedBox(height: 20),

            // HASIL PENCARIAN
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final warga = _searchResults[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              color: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green[50],
                                  child: const Icon(Icons.person, color: Colors.green),
                                ),
                                title: Text(
                                  warga['nama_lengkap'] ?? "Tanpa Nama", 
                                  style: const TextStyle(fontWeight: FontWeight.bold)
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("NIK: ${warga['nik'] ?? '-'}"),
                                    Text("Alamat: ${warga['alamat'] ?? '-'}", style: const TextStyle(fontSize: 11)),
                                  ],
                                ),
                                trailing: const Icon(Icons.verified, size: 18, color: Colors.blue), // Icon Verified
                                onTap: () {
                                  _showWargaDetail(warga);
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text("Belum ada warga yang terverifikasi", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

// GANTI FUNGSI INI DI DALAM search_screen.dart

  void _showWargaDetail(Map<String, dynamic> warga) {
    bool isProcessing = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Detail Warga"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _detailRow("Nama", warga['nama_lengkap']),
                  _detailRow("NIK", warga['nik']),
                  _detailRow("KK", warga['no_kk']),
                  // _detailRow("Alamat", warga['alamat']), // Alamat kita skip dulu
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[100], 
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: const Text(
                      "Status: TERVERIFIKASI ✅", 
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
              actions: [
                // TOMBOL BATALKAN VERIFIKASI (UNDO)
                TextButton(
                  onPressed: isProcessing ? null : () async {
                    // Konfirmasi dulu biar gak kepencet lagi
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Batalkan Verifikasi?"),
                        content: const Text("Warga ini akan dikembalikan ke status 'Menunggu' dan masuk ke halaman Notifikasi lagi."),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Ya, Kembalikan")),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      setStateDialog(() => isProcessing = true);
                      
                      // Panggil API untuk ubah status jadi 'pending'
                      // Pastikan ID dikonversi ke int
                      int idWarga = int.tryParse(warga['id'].toString()) ?? 0;
                      
                      // Kita pakai fungsi verifyWargaBaru yang sudah ada, kirim status 'pending'
                      bool success = await ApiService.verifyWargaBaru(idWarga, 'pending');

                      if (mounted) {
                        Navigator.pop(context); // Tutup Dialog Detail
                        if (success) {
                          _searchWarga(""); // Refresh Halaman Search (Data akan hilang)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Verifikasi dibatalkan. Data kembali ke Notifikasi anulir ↩️"))
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Gagal membatalkan verifikasi"))
                          );
                        }
                      }
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: isProcessing 
                    ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("Batalkan Verifikasi"),
                ),
                
                // TOMBOL TUTUP BIASA
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Tutup"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 60, child: Text(label, style: const TextStyle(color: Colors.grey))),
          const Text(": "),
          Expanded(child: Text(value ?? "-", style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}