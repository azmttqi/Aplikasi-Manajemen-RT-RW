import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // --- DUMMY DATA 1: PENDAFTARAN WARGA BARU ---
  final List<Map<String, dynamic>> _newRegistrations = [
    {
      "id": 101,
      "nama": "Ahmad Dani",
      "alamat": "Blok A No. 12",
      "waktu": "10 Menit lalu",
      "status": "Menunggu", // Status: Menunggu, Disetujui, Ditolak
    },
    {
      "id": 102,
      "nama": "Siti Aminah",
      "alamat": "Blok B No. 05",
      "waktu": "1 Jam lalu",
      "status": "Ditolak", 
    },
  ];

  // --- DUMMY DATA 2: PENGAJUAN PERUBAHAN DATA ---
  final List<Map<String, dynamic>> _dataUpdates = [
    {
      "id": 201,
      "nama": "Budi Santoso",
      "perihal": "Ubah Nomor KK & Foto",
      "waktu": "Baru saja",
      "status": "Menunggu",
      "data_lama": "KK Lama: 3201...",
      "data_baru": "KK Baru: 3205..."
    },
    {
      "id": 202,
      "nama": "Rina Wati",
      "perihal": "Ganti Status Perkawinan",
      "waktu": "Kemarin",
      "status": "Disetujui",
      "data_lama": "Belum Kawin",
      "data_baru": "Kawin"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Background Cream
      appBar: AppBar(
        title: const Text("Permohonan Warga", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          tabs: const [
            Tab(text: "Verifikasi Akun"), // Tab 1
            Tab(text: "Update Data"),     // Tab 2
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // --- HALAMAN 1: LIST PENDAFTARAN BARU ---
          _buildRegistrationList(),

          // --- HALAMAN 2: LIST UPDATE DATA ---
          _buildUpdateDataList(),
        ],
      ),
    );
  }

  // WIDGET: List Pendaftaran Baru
  Widget _buildRegistrationList() {
    if (_newRegistrations.isEmpty) return _emptyState("Belum ada pendaftaran baru");
    
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _newRegistrations.length,
      itemBuilder: (context, index) {
        final item = _newRegistrations[index];
        return _buildCard(
          title: item['nama'],
          subtitle: "Daftar Warga Baru • ${item['alamat']}",
          time: item['waktu'],
          status: item['status'],
          icon: Icons.person_add,
          color: Colors.blue,
          onTap: () => _showActionDialog(item, isRegistration: true),
        );
      },
    );
  }

  // WIDGET: List Update Data
  Widget _buildUpdateDataList() {
    if (_dataUpdates.isEmpty) return _emptyState("Belum ada pengajuan data");

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _dataUpdates.length,
      itemBuilder: (context, index) {
        final item = _dataUpdates[index];
        return _buildCard(
          title: item['nama'],
          subtitle: "${item['perihal']}",
          time: item['waktu'],
          status: item['status'],
          icon: Icons.edit_document,
          color: Colors.orange,
          onTap: () => _showActionDialog(item, isRegistration: false),
        );
      },
    );
  }

  // WIDGET: Kartu Umum (Bisa dipakai kedua tab)
  Widget _buildCard({
    required String title,
    required String subtitle,
    required String time,
    required String status,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    // Tentukan Warna Badge Status
    Color statusColor = Colors.grey;
    if (status == 'Menunggu') statusColor = Colors.orange;
    if (status == 'Disetujui') statusColor = Colors.green;
    if (status == 'Ditolak') statusColor = Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 5),
                Text(time, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            )
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            status,
            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  // DIALOG: Pop-up saat diklik (Untuk Aksi Terima/Tolak)
  void _showActionDialog(Map<String, dynamic> item, {required bool isRegistration}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isRegistration ? "Verifikasi Akun" : "Perubahan Data"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nama: ${item['nama']}", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              if (!isRegistration) ...[
                // Jika Update Data, tampilkan perbandingannya
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.red[50],
                  width: double.infinity,
                  child: Text("Lama: ${item['data_lama']}"),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.green[50],
                  width: double.infinity,
                  child: Text("Baru: ${item['data_baru']}"),
                ),
                const SizedBox(height: 10),
              ] else ...[
                 // Jika Pendaftaran Baru
                 Text("Alamat: ${item['alamat']}"),
              ],

              const Text("Tindakan:", style: TextStyle(color: Colors.grey)),
            ],
          ),
          actions: [
            if (item['status'] == 'Menunggu') ...[
              // Tombol Tolak
              OutlinedButton(
                onPressed: () {
                  setState(() => item['status'] = 'Ditolak');
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Permohonan Ditolak ❌")));
                },
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Tolak"),
              ),
              // Tombol Terima
              ElevatedButton(
                onPressed: () {
                  setState(() => item['status'] = 'Disetujui');
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Permohonan Disetujui ✅")));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Setujui", style: TextStyle(color: Colors.white)),
              ),
            ] else ...[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Tutup"),
              )
            ]
          ],
        );
      },
    );
  }

  Widget _emptyState(String text) {
    return Center(child: Text(text, style: const TextStyle(color: Colors.grey)));
  }
}