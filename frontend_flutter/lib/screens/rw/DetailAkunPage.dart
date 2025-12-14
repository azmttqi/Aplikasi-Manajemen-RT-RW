import 'package:flutter/material.dart';
import '../../services/api_service.dart'; // Import Service

class DetailAkunPage extends StatefulWidget {
  final int idUser; // ID User untuk diverifikasi
  final String nik;
  final String nama;
  final String rt;
  final String judulHalaman;
  final String labelInfo;
  final bool isVerified; // Status saat ini (untuk disable tombol jika sudah aktif)

  const DetailAkunPage({
    super.key,
    required this.idUser, // Wajib diisi
    required this.nik,
    required this.nama,
    required this.rt,
    this.judulHalaman = "Detail Akun",
    this.labelInfo = "Info Akun / NIK",
    this.isVerified = false, // Default false
  });

  @override
  State<DetailAkunPage> createState() => _DetailAkunPageState();
}

class _DetailAkunPageState extends State<DetailAkunPage> {
  bool _isLoading = false;
  late bool _currentStatus; // Untuk update tampilan realtime tanpa refresh

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.isVerified;
  }

  void _handleVerifikasi() async {
    setState(() => _isLoading = true);

    // Panggil API
    bool success = await ApiService.verifyAccount(widget.idUser);

    setState(() => _isLoading = false);

    if (success) {
      setState(() => _currentStatus = true); // Ubah jadi hijau
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Akun berhasil diverifikasi! ✅")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memverifikasi akun ❌"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E5),
      appBar: AppBar(
        title: Text(widget.judulHalaman, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color (0xFF678267),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // KARTU DATA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Nama Lengkap", widget.nama, isBold: true),
                  const Divider(height: 30),
                  _buildDetailRow(widget.labelInfo, widget.nik),
                  const SizedBox(height: 15),
                  _buildDetailRow("Wilayah RT", "RT ${widget.rt}"),
                  const SizedBox(height: 15),
                  
                  // Status Baris
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Status Akun", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _currentStatus ? Colors.green[100] : Colors.orange[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _currentStatus ? "AKTIF" : "PENDING",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _currentStatus ? Colors.green[800] : Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const Spacer(),

            // TOMBOL VERIFIKASI (Hanya muncul jika belum verified)
            if (!_currentStatus)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerifikasi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                      : const Text("Verifikasi Akun Ini", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            
            const SizedBox(height: 15),

            // Tombol Kembali
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Kembali", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: Colors.black87)),
      ],
    );
  }
}