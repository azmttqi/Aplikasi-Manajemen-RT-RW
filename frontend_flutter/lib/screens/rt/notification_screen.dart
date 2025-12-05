import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // DATA KHUSUS RT (Warga, Siskamling, Surat)
  List<Map<String, dynamic>> notifications = [
    {
      "id": 1,
      "title": "Verifikasi Warga Baru",
      "body": "Warga a.n. Budi Santoso (Blok A4) menunggu verifikasi Anda.",
      "time": "Baru saja",
      "type": "alert", // alert (Penting/Orange)
      "isRead": false,
    },
    {
      "id": 2,
      "title": "Jadwal Siskamling",
      "body": "Mengingatkan jadwal ronda malam ini: Kelompok Bapak Heru.",
      "time": "5 Jam yang lalu",
      "type": "info", // info (Hijau)
      "isRead": true,
    },
    {
      "id": 3,
      "title": "Permintaan Surat Pengantar",
      "body": "Ibu Siti mengajukan surat pengantar pembuatan KTP.",
      "time": "Kemarin",
      "type": "alert",
      "isRead": true,
    },
     {
      "id": 4,
      "title": "Kerja Bakti RT 001",
      "body": "Minggu besok kumpul di lapangan untuk pembersihan selokan.",
      "time": "2 Hari yang lalu",
      "type": "success",
      "isRead": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Background Cream
      appBar: AppBar(
        title: const Text(
          "Notifikasi RT", // Judul Spesifik
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
            tooltip: "Tandai semua dibaca",
            onPressed: () {
              setState(() {
                for (var n in notifications) {
                  n['isRead'] = true;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Semua notifikasi ditandai sudah dibaca")),
              );
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
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      notifications.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Notifikasi dihapus")),
                    );
                  },
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.red[800]),
                  ),
                  child: _buildNotificationCard(item),
                );
              },
            ),
    );
  }

  // Widget Kartu (Sama stylenya dengan RW biar konsisten)
  Widget _buildNotificationCard(Map<String, dynamic> item) {
    bool isAlert = item['type'] == 'alert';
    bool isRead = item['isRead'];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isRead 
            ? Border.all(color: Colors.transparent)
            : Border.all(color: Colors.orange.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isAlert ? Colors.orange[50] : Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAlert ? Icons.priority_high : Icons.notifications_none,
              color: isAlert ? Colors.orange : Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isRead ? Colors.black87 : Colors.black,
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  item['body'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  item['time'],
                  style: TextStyle(color: Colors.grey[400], fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 15),
          Text("Belum ada notifikasi RT", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }
}