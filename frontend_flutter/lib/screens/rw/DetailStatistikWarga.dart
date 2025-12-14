import 'package:flutter/material.dart';

class DetailStatistikWarga extends StatelessWidget {
  final String total;
  final String laki;
  final String perempuan;

  const DetailStatistikWarga({
    super.key,
    required this.total,
    required this.laki,
    required this.perempuan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E5),
      appBar: AppBar(
        title: const Text("Statistik Warga", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Kartu Total
            _buildStatCard("Total Warga", total, Icons.groups, Colors.blue),
            const SizedBox(height: 20),
            
            // Baris Gender
            Row(
              children: [
                Expanded(child: _buildStatCard("Laki-laki", laki, Icons.male, Colors.cyan)),
                const SizedBox(width: 15),
                Expanded(child: _buildStatCard("Perempuan", perempuan, Icons.female, Colors.pink)),
              ],
            ),
            
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Kembali"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}