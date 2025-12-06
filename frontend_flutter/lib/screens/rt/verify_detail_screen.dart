import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'edit_warga_screen.dart'; // Pastikan file ini sudah ada (kita buat di langkah sebelumnya)

class VerifyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const VerifyDetailScreen({super.key, required this.data});

  @override
  State<VerifyDetailScreen> createState() => _VerifyDetailScreenState();
}

class _VerifyDetailScreenState extends State<VerifyDetailScreen> {
  bool _isLoading = false;

  // --- FUNGSI VERIFIKASI (UPDATE STATUS) ---
  void _prosesVerifikasi(String status) async {
    setState(() => _isLoading = true);

    final int idWarga = widget.data['id_warga'] ?? 0;
    bool sukses = await ApiService.updateStatusWarga(idWarga, status);

    setState(() => _isLoading = false);

    if (mounted) {
      if (sukses) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'pending' 
                ? "Status dikembalikan ke Menunggu ↺" 
                : "Status berhasil diperbarui! ✅"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mengupdate status"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- FUNGSI HAPUS WARGA (BARU) ---
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Data Warga?"),
        content: const Text(
          "Apakah Anda yakin? Data yang dihapus tidak dapat dikembalikan. \n\nJika warga hanya pindah, sebaiknya edit datanya saja.",
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Batal")
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Tutup Dialog
              
              setState(() => _isLoading = true); // Loading mulai
              
              final int idWarga = widget.data['id_warga'] ?? 0;
              
              // Panggil API Hapus
              bool sukses = await ApiService.deleteWarga(idWarga);
              
              if (mounted) {
                setState(() => _isLoading = false); // Loading selesai
                
                if (sukses) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data warga berhasil dihapus 🗑️"))
                  );
                  Navigator.pop(context, true); // Kembali ke list & refresh
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
    final d = widget.data;
    String status = (d['status_verifikasi'] ?? 'pending').toString().toUpperCase();

    Color statusColor = Colors.orange;
    if (status == 'DISETUJUI') statusColor = Colors.green;
    if (status == 'DITOLAK') statusColor = Colors.red;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text("Detail Warga", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          // TOMBOL EDIT (PENSIL)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            tooltip: "Edit Data",
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditWargaScreen(data: widget.data),
                ),
              );
              if (result == true) {
                Navigator.pop(context, true);
              }
            },
          ),
          
          // TOMBOL HAPUS (SAMPAH) - BARU
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
            // --- KARTU PROFIL ---
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
                  _buildInfoRow("Tempat Lahir", d['tempat_lahir'] ?? "-"),
                  _buildInfoRow("Tanggal Lahir", d['tanggal_lahir'] ?? "-"),
                  _buildInfoRow("Jenis Kelamin", d['jenis_kelamin'] ?? "-"),
                  _buildInfoRow("Agama", d['agama'] ?? "-"),
                  _buildInfoRow("Status Kawin", d['status_perkawinan'] ?? "-"),
                  _buildInfoRow("Pekerjaan", d['pekerjaan'] ?? "-"),
                  _buildInfoRow("Email", d['email'] ?? "-"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- TOMBOL LOGIKA STATUS ---
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (status != 'PENDING') 
              // Tombol Reset (Rollback)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Icon(
                      status == 'DISETUJUI' ? Icons.check_circle : Icons.cancel, 
                      color: status == 'DISETUJUI' ? Colors.green : Colors.red,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text("Status: $status", style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _prosesVerifikasi("pending"); // Reset ke Pending
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text("Batalkan & Tinjau Ulang"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue[700],
                          side: BorderSide(color: Colors.blue[200]!),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              // Tombol Terima / Tolak
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
                      child: const Text("Setujui Warga", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

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