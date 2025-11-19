// screens/rw/account_search_screen.dart

import 'package:flutter/material.dart';
import 'DetailAkunPage.dart'; 

class AccountSearchScreen extends StatelessWidget {
  const AccountSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🚀 BNAV Fix: Menggunakan Material sebagai root, BUKAN Scaffold
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor, // Ambil warna latar belakang dari tema
      child: Column(
        children: [
          // --- Bagian Atas: Logo (Header Kustom) ---
          SizedBox(
            height: 150.0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 30.0),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.home_work, color: Colors.green, size: 40), 
                    const Text('Manajemen RT/RW', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Text('Membangun Komunitas Cerdas', style: TextStyle(color: Colors.green, fontSize: 10)),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          // --- Isi Halaman ---
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100.0), // Padding bawah untuk BNAV
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: Text('Pencarian Akun RT', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    // --- Kolom Pencarian ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Cari NIK atau Nama Warga',
                                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                fillColor: Colors.grey[100],
                                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber, 
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),
                            child: const Text('Cari', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // --- Tabel Data ---
                    const AccountDataTable(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Widget untuk Tabel Data (Perbaikan Navigasi) ---
class AccountDataTable extends StatelessWidget {
  const AccountDataTable({super.key});

  final List<Map<String, String>> _data = const [
    {'nik': '32145xxxxxxxxxxx', 'nama': 'Andianto Julian', 'rt': '001'},
    {'nik': '32145xxxxxxxxxxx', 'nama': 'Muhammad', 'rt': '010'},
  ];

  void _navigateToDetail(BuildContext context, Map<String, String> rowData) {
    // Navigasi lokal: push halaman detail
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailAkunPage(
          nik: rowData['nik']!, 
          nama: rowData['nama']!,
          rt: rowData['rt']!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // ... (Header Tabel tetap sama)
          
          // Baris Data
          ..._data.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, String> row = entry.value;
            Color rowColor = index.isEven ? Colors.white : Colors.green[50]!;

            return InkWell( 
              onTap: () => _navigateToDetail(context, row), 
              child: Container(
                color: rowColor,
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(row['nik']!, style: const TextStyle(fontSize: 12))),
                    Expanded(flex: 2, child: Text(row['nama']!, style: const TextStyle(fontSize: 12))),
                    Expanded(flex: 1, child: Text(row['rt']!, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
                  ],
                ),
              ),
            );
          }).toList(),
          Container(height: 1, color: Colors.grey[300]),
        ],
      ),
    );
  }
}