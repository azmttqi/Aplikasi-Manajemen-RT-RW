import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manajemen RT/RW',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const AccountSearchScreen(),
    );
  }
}

class AccountSearchScreen extends StatelessWidget {
  const AccountSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Bagian Atas: Logo ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo_rt_rw.png', // Ganti dengan path logo Anda
                      height: 80,
                    ),
                    const Text(
                      'Manajemen RT/RW',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Membangun Komunitas Cerdas',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      // --- Isi Halaman ---
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                'Pencarian Akun RT',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Logika pencarian di sini
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber, // Warna kuning seperti di UI
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Cari',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // --- Tabel Data ---
            const AccountDataTable(),
            const SizedBox(height: 100), // Memberi ruang di bawah tabel
          ],
        ),
      ),
      // --- Bottom Navigation Bar ---
      bottomNavigationBar: BottomAppBar(
        color: Colors.green[800],
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white, size: 30),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.folder, color: Colors.white, size: 30),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white, size: 30),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.person, color: Colors.white, size: 30),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Widget untuk Tabel Data ---
class AccountDataTable extends StatelessWidget {
  const AccountDataTable({super.key});

  // Data dummy untuk tabel
  final List<Map<String, String>> _data = const [
    {'nik': '32145xxxxxxxxxxx', 'nama': 'Andianto Julian', 'rt': '001'},
    {'nik': '32145xxxxxxxxxxx', 'nama': 'Sulitiawati', 'rt': '002'},
    {'nik': '32145xxxxxxxxxxx', 'nama': 'Melody Aggreyani', 'rt': '003'},
    {'nik': '32145xxxxxxxxxxx', 'nama': 'Julian Septian', 'rt': '004'},
    {'nik': '32145xxxxxxxxxxx', 'nama': 'Kresnayati', 'rt': '005'},
    {'nik': '32145xxxxxxxxxxx', 'nama': 'Lahmat', 'rt': '006'},
    {'nik': '32145xxxxxxxxxxx', 'nama': 'Nato', 'rt': '007'},
    {'nik': '32145xxxxxxxxxxx', 'nama': 'Dawialdi', 'rt': '008'},
    {'nik': '32145xxxxxxxxxxx', 'nama': 'QismayatuI ALaa', 'rt': '009'},
    {'nik': '32145xxxxxxxxxxx', 'nama': 'Muhammad', 'rt': '010'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Header Tabel (sesuai warna UI)
          Container(
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('Nomor Induk Kependudukan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('Nama Lengkap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('RT', textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
          // Baris Data
          ..._data.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, String> row = entry.value;
            // Background bergantian: Putih dan Hijau Muda
            Color rowColor = index.isEven ? Colors.white : Colors.green[50]!;

            return Container(
              color: rowColor,
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(row['nik']!, style: const TextStyle(fontSize: 12)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(row['nama']!, style: const TextStyle(fontSize: 12)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(row['rt']!, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            );
          }).toList(),
          // Garis bawah untuk baris terakhir
          Container(
            height: 1,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
