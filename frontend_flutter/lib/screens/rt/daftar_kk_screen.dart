import 'package:flutter/material.dart';

class DaftarKkScreen extends StatefulWidget {
  const DaftarKkScreen({super.key});

  @override
  _DaftarKkScreenState createState() => _DaftarKkScreenState();
}

class _DaftarKkScreenState extends State<DaftarKkScreen> {
  // --- DATA DUMMY (Nanti diganti dengan data dari API) ---
  final List<Map<String, dynamic>> _allKk = [
    {
      "kepala_keluarga": "Budi Santoso",
      "no_kk": "3201123456780001",
      "status_rumah": "Milik Sendiri", // Tetap
      "alamat": "Blok A1 No. 5"
    },
    {
      "kepala_keluarga": "Siti Aminah",
      "no_kk": "3201123456780002",
      "status_rumah": "Kontrak", // Sewa
      "alamat": "Blok B2 No. 10"
    },
    {
      "kepala_keluarga": "Joko Anwar",
      "no_kk": "3201123456780003",
      "status_rumah": "Milik Sendiri",
      "alamat": "Blok A3 No. 12"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E5), // Background Cream
      appBar: AppBar(
        title: const Text(
          "Daftar Kartu Keluarga",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // --- 1. SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari Nama Kepala Keluarga / No KK...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),

          // --- 2. LIST DATA ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _allKk.length,
              itemBuilder: (context, index) {
                final data = _allKk[index];
                final isTetap = data['status_rumah'] == "Milik Sendiri";

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Ikon Rumah (Kiri)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isTetap ? Colors.orange.withOpacity(0.1) : Colors.purple.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isTetap ? Icons.home : Icons.business,
                          color: isTetap ? Colors.orange : Colors.purple,
                          size: 24,
                        ),
                      ),
                      
                      const SizedBox(width: 15),

                      // Info Text (Tengah)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['kepala_keluarga'],
                              style: const TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                                color: Colors.black87
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "No KK: ${data['no_kk']}",
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            Text(
                              data['alamat'],
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),

                      // Badge Status (Kanan)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isTetap ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isTetap ? "Tetap" : "Sewa",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isTetap ? Colors.green : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}