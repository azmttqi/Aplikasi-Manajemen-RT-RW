import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'edit_warga_screen.dart'; // Pastikan file ini ada

class DetailWargaScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailWargaScreen({super.key, required this.data});

  @override
  State<DetailWargaScreen> createState() => _DetailWargaScreenState();
}

class _DetailWargaScreenState extends State<DetailWargaScreen> {
  bool _isLoading = false;
  late Map<String, dynamic> _currentData; // Untuk menampung data update

  @override
  void initState() {
    super.initState();
    _currentData = widget.data; // Inisialisasi data awal
  }

  // --- FUNGSI VERIFIKASI (UPDATE STATUS) ---
  void _prosesVerifikasi(String status) async {
    setState(() => _isLoading = true);

    // Ambil ID Warga (Cek key id atau id_warga)
    final rawId = _currentData['id'] ?? _currentData['id_warga'];
    final int idWarga = int.tryParse(rawId.toString()) ?? 0;

    // Panggil API verifyWargaBaru
    bool sukses = await ApiService.verifyWargaBaru(idWarga, status);

    setState(() => _isLoading = false);

    if (mounted) {
      if (sukses) {
        String pesan = "";
        if (status == 'pending') pesan = "Status dikembalikan ke Menunggu ↺";
        else if (status == 'disetujui') pesan = "Warga berhasil Disetujui ✅";
        else if (status == 'ditolak') pesan = "Warga Ditolak ❌";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(pesan), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Refresh halaman sebelumnya
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mengupdate status"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- FUNGSI HAPUS WARGA ---
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Data Warga?"),
        content: const Text(
          "Apakah Anda yakin? Data yang dihapus tidak dapat dikembalikan.",
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
              setState(() => _isLoading = true);
              
              final rawId = _currentData['id'] ?? _currentData['id_warga'];
              final int idWarga = int.tryParse(rawId.toString()) ?? 0;
              
              bool sukses = await ApiService.deleteWarga(idWarga);
              
              if (mounted) {
                setState(() => _isLoading = false);
                if (sukses) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data warga berhasil dihapus 🗑️"))
                  );
                  Navigator.pop(context, true); // Kembali & refresh
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Gagal menghapus data"), backgroundColor: Colors.red)
                  );
                }
              }
            },
            child: const Text("Hapus Permanen", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data terbaru
    final d = _currentData;
    // Normalisasi status ke Uppercase biar gampang dicek
    String status = (d['status_verifikasi'] ?? 'pending').toString().toUpperCase();

    // Tentukan warna badge
    Color statusColor = Colors.orange;
    if (status == 'DISETUJUI' || status == 'VERIFIED') statusColor = Colors.green;
    if (status == 'DITOLAK') statusColor = Colors.red;

    // [Updated] Ambil alamat dengan fallback key
    String alamat = d['alamat_lengkap'] ?? d['alamat'] ?? "-";

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text("Biodata Lengkap", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          // TOMBOL EDIT (PENSIL)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            tooltip: "Edit Data",
            onPressed: () async {
              // Navigasi ke Halaman Edit
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditWargaScreen(warga: d),
                ),
              );

              // Jika kembali dengan sukses (true), refresh halaman ini
              if (result == true) {
                 Navigator.pop(context, true); 
              }
            },
          ),
          
          // TOMBOL HAPUS (SAMPAH)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: "Hapus Warga",
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- KARTU HEADER PROFIL ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.person, size: 50, color: Colors.green),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    d['nama_lengkap'] ?? "Tanpa Nama",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- INFO DETAIL ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Informasi Pribadi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(height: 20),
                  _buildInfoRow("NIK", d['nik'] ?? "-"),
                  _buildInfoRow("No. KK", d['no_kk'] ?? "-"),
                  
                  // [BARU] Menambahkan field Alamat
                  _buildInfoRow("Alamat", alamat), 

                  _buildInfoRow("Tempat Lahir", d['tempat_lahir'] ?? "-"),
                  _buildInfoRow("Tanggal Lahir", d['tanggal_lahir'] ?? "-"),
                  _buildInfoRow("Jenis Kelamin", d['jenis_kelamin'] ?? "-"),
                  _buildInfoRow("Agama", d['agama'] ?? "-"),
                  _buildInfoRow("Status Kawin", d['status_perkawinan'] ?? "-"),
                  _buildInfoRow("Pekerjaan", d['pekerjaan'] ?? "-"),
                  _buildInfoRow("Kewarganegaraan", d['kewarganegaraan'] ?? "-"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- LOGIKA TOMBOL BAWAH ---
            if (_isLoading)
               const Center(child: CircularProgressIndicator())
            
            // KONDISI 1: Status PENDING (Muncul Tombol Terima/Tolak)
            else if (status == 'PENDING' || status == 'MENUNGGU') 
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _prosesVerifikasi("ditolak"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 0,
                      ),
                      child: const Text("Tolak", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _prosesVerifikasi("disetujui"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text("Setujui", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )

            // KONDISI 2: Status DISETUJUI (Muncul Tombol Batalkan)
            else if (status == 'DISETUJUI' || status == 'VERIFIED')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      "Warga ini sudah Terverifikasi", 
                      style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    
                    // TOMBOL BATALKAN
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                           // Konfirmasi Dialog
                           bool confirm = await showDialog(
                             context: context,
                             builder: (ctx) => AlertDialog(
                               title: const Text("Batalkan Verifikasi?"),
                               content: const Text("Status warga akan kembali menjadi 'Menunggu' dan warga ini akan dipindahkan kembali ke menu Notifikasi."),
                               actions: [
                                 TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
                                 TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Ya, Kembalikan")),
                               ],
                             )
                           ) ?? false;

                           if (confirm) {
                             _prosesVerifikasi("pending"); // Reset status ke pending
                           }
                        },
                        icon: const Icon(Icons.restore, size: 18),
                        label: const Text("Batalkan & Tinjau Ulang"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange[800],
                          side: BorderSide(color: Colors.orange[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              )

            // KONDISI 3: Status Ditolak
            else 
              Center(
                 child: Text("Status: $status", style: const TextStyle(color: Colors.grey)),
              ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget Pembantu untuk Baris Info
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Colors.grey))),
          const Text(": ", style: TextStyle(color: Colors.grey)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}