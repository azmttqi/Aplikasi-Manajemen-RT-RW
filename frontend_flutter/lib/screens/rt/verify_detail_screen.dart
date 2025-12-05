import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class VerifyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data; // Menerima data warga dari halaman list

  const VerifyDetailScreen({super.key, required this.data});

  @override
  State<VerifyDetailScreen> createState() => _VerifyDetailScreenState();
}

class _VerifyDetailScreenState extends State<VerifyDetailScreen> {
  bool _isLoading = false;

  // Fungsi Verifikasi (Panggil API Update)
  void _prosesVerifikasi(String status) async {
    setState(() => _isLoading = true);

    // Ambil ID Warga
    final int idWarga = widget.data['id_warga'] ?? 0;
    
    // Panggil API
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
        // Kembali ke halaman List dan kirim sinyal 'true' agar list direfresh
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mengupdate status"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    // Ambil status, pastikan uppercase biar mudah dicek
    String status = (d['status_verifikasi'] ?? 'pending').toString().toUpperCase();

    // Tentukan warna status
    Color statusColor = Colors.orange;
    if (status == 'DISETUJUI') statusColor = Colors.green;
    if (status == 'DITOLAK') statusColor = Colors.red;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Background Cream
      appBar: AppBar(
        title: const Text("Detail Warga", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- KARTU PROFIL UTAMA ---
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
                  // Badge Status
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

            // --- INFO DETAIL LENGKAP ---
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

            // ===============================================
            // 👇 LOGIKA TOMBOL AKSI (DINAMIS)
            // ===============================================
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())

            else if (status != 'PENDING') 
              // JIKA SUDAH SELESAI -> TAMPILKAN TOMBOL KOREKSI (RESET)
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
                    Text(
                      "Status: $status",
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Salah pencet? Anda bisa membatalkannya.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    
                    const SizedBox(height: 15),

                    // TOMBOL RESET
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Dialog Konfirmasi
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Tinjau Ulang?"),
                              content: const Text("Status warga akan dikembalikan ke 'Menunggu' agar bisa diverifikasi ulang."),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Tutup dialog
                                    _prosesVerifikasi("pending"); // PROSES RESET
                                  },
                                  child: const Text("Ya, Kembalikan"),
                                ),
                              ],
                            ),
                          );
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
              // JIKA STATUS == PENDING -> TAMPILKAN TOMBOL TERIMA / TOLAK
              Row(
                children: [
                  // Tombol Tolak
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
                  // Tombol Setuju
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

  // Widget Helper untuk Baris Info
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