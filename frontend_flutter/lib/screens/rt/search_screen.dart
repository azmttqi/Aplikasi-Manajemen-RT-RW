import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'edit_warga_screen.dart'; // Pastikan path-nya benar
import 'detail_warga_screen.dart'; // Pastikan dia memanggil file yang ada di folder yang sama

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
      backgroundColor: const Color (0xFFF8F2E5),
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
                                onTap: () async {
                                  bool? refreshNeeded = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailWargaScreen(data: warga), // Panggil Detail Screen
                                    ),
                                  );

                                  if (refreshNeeded == true && mounted) {
                                    _searchWarga(""); // Refresh list kalau data berubah
                                  }
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
              // ---------------------------------------------------------
              // 1. BAGIAN JUDUL & TOMBOL EDIT (BARU)
              // ---------------------------------------------------------
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Detail Warga"),
                  // 👇 TOMBOL PENSIL (EDIT)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: "Edit Data Lengkap",
                    onPressed: () async {
                      Navigator.pop(context); // Tutup popup dulu
                      
                      // Pindah ke layar edit yang baru kita buat (Langkah 4)
                      bool? result = await Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => EditWargaScreen(warga: warga),
                        ),
                      );

                      // Jika berhasil edit (result == true), refresh halaman list
                      if (result == true && mounted) {
                        _searchWarga(""); // Refresh data agar perubahan terlihat
                      }
                    },
                  )
                ],
              ),
              
              // ---------------------------------------------------------
              // 2. BAGIAN KONTEN (SAMA SEPERTI SEBELUMNYA)
              // ---------------------------------------------------------
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _detailRow("Nama", warga['nama_lengkap']),
                  _detailRow("NIK", warga['nik']),
                  _detailRow("KK", warga['no_kk']),
                  // Tampilkan data lengkap lainnya jika ada
                  _detailRow("TTL", "${warga['tempat_lahir'] ?? '-'}, ${warga['tanggal_lahir'] ?? '-'}"),
                  _detailRow("Agama", warga['agama']),
                  _detailRow("Pekerjaan", warga['pekerjaan']),
                  
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

              // ---------------------------------------------------------
              // 3. BAGIAN TOMBOL BAWAH (SAMA SEPERTI SEBELUMNYA)
              // ---------------------------------------------------------
              actions: [
                // TOMBOL BATALKAN VERIFIKASI (UNDO)
                TextButton(
                  onPressed: isProcessing ? null : () async {
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
                      
                      // Pastikan ID dikonversi ke int dengan benar
                      // Cek apakah key-nya 'id' atau 'id_warga'
                      var rawId = warga['id'] ?? warga['id_warga'];
                      int idWarga = int.tryParse(rawId.toString()) ?? 0;
                      
                      bool success = await ApiService.verifyWargaBaru(idWarga, 'pending');

                      if (mounted) {
                        Navigator.pop(context); // Tutup Dialog Detail
                        if (success) {
                          _searchWarga(""); // Refresh Halaman Search
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Verifikasi dibatalkan ↩️"))
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
                
                // TOMBOL TUTUP
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