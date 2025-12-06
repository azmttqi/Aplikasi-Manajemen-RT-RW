import 'package:flutter/material.dart';

class WargaNotificationScreen extends StatefulWidget {
  const WargaNotificationScreen({super.key});

  @override
  State<WargaNotificationScreen> createState() => _WargaNotificationScreenState();
}

class _WargaNotificationScreenState extends State<WargaNotificationScreen> {
  // DATA DUMMY KHUSUS WARGA
  List<Map<String, dynamic>> notifications = [
    {
      "id": 1,
      "title": "Status Data Anda",
      "body": "Selamat! Data kependudukan Anda telah diverifikasi oleh Ketua RT.",
      "time": "Baru saja",
      "type": "success", // Hijau
      "isRead": false,
    },
    {
      "id": 2,
      "title": "Iuran Sampah & Keamanan",
      "body": "Tagihan bulan Desember sebesar Rp 25.000 sudah terbit.",
      "time": "5 Jam yang lalu",
      "type": "alert", // Oranye
      "isRead": true,
    },
    {
      "id": 3,
      "title": "Undangan Kerja Bakti",
      "body": "Minggu ini akan diadakan kerja bakti membersihkan selokan utama.",
      "time": "Kemarin",
      "type": "info", // Biru/Hijau
      "isRead": true,
    },
    {
      "id": 4,
      "title": "Pengumuman Pemadaman Listrik",
      "body": "Akan ada pemadaman bergilir di wilayah RT 005 pada hari Selasa.",
      "time": "2 Hari yang lalu",
      "type": "alert",
      "isRead": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Cream Background
      appBar: AppBar(
        title: const Text(
          "Notifikasi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Hapus tombol back
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.green),
            tooltip: "Tandai semua dibaca",
            onPressed: () {
              setState(() {
                for (var n in notifications) {
                  n['isRead'] = true;
                }
              });
            },
          )
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return Dismissible(
                  key: Key(item['id'].toString()),
                  onDismissed: (dir) {
                    setState(() {
                      notifications.removeAt(index);
                    });
                  },
                  background: Container(color: Colors.red),
                  child: _buildNotificationCard(item),
                );
              },
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    bool isAlert = item['type'] == 'alert';
    bool isSuccess = item['type'] == 'success';
    bool isRead = item['isRead'];

    Color iconColor = Colors.blue;
    IconData iconData = Icons.info;

    if (isAlert) {
      iconColor = Colors.orange;
      iconData = Icons.warning_amber_rounded;
    } else if (isSuccess) {
      iconColor = Colors.green;
      iconData = Icons.check_circle_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isRead 
            ? Border.all(color: Colors.transparent) 
            : Border.all(color: iconColor.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isRead ? Colors.black87 : Colors.black,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(item['body'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 8),
                Text(item['time'], style: TextStyle(color: Colors.grey[400], fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("Tidak ada notifikasi"));
  }
}