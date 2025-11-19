// detail_akun_page.dart (Halaman Baru)

import 'package:flutter/material.dart';

class DetailAkunPage extends StatelessWidget {
  final String nik;
  final String nama;
  final String rt;

  // Menerima data dari halaman sebelumnya
  const DetailAkunPage({super.key, required this.nik, required this.nama, required this.rt});

  @override
  Widget build(BuildContext context) {
    // 🚀 Halaman detail ini memerlukan Scaffold dan AppBar-nya sendiri
    return Scaffold( 
      appBar: AppBar(
        title: const Text('Detail Akun Warga'),
        backgroundColor: Colors.green,
        // Tombol kembali otomatis muncul karena ini adalah halaman yang dipush
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama Lengkap: $nama', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('NIK: $nik', style: const TextStyle(fontSize: 16)),
            Text('RT: $rt', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            // Tombol kembali manual
            ElevatedButton(
              onPressed: () {
                // 🚀 Navigasi Kembali: Menutup halaman Detail dan kembali ke AccountSearchScreen
                Navigator.pop(context); 
              },
              child: const Text('Tutup Detail'),
            ),
          ],
        ),
      ),
    );
  }
}