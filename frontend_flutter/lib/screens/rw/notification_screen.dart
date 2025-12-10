import 'package:flutter/material.dart';
import '../../services/api_service.dart';
// import 'package:intl/intl.dart'; // Opsional: Untuk format tanggal (perlu 'flutter pub add intl')

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> _notifList = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _fetchNotif();
  }

  void _fetchNotif() async {
    final data = await ApiService.getRwNotifications();
    if (mounted) {
      setState(() {
        _notifList = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6E6),
      appBar: AppBar(
        title: const Text("Notifikasi", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false, // Hilangkan tombol back (karena ini menu utama)
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifList.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("Belum ada notifikasi baru"),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifList.length,
                  itemBuilder: (context, index) {
                    final item = _notifList[index];
                    // Format Tanggal (Sederhana)
                    final String rawDate = item['created_at'] ?? DateTime.now().toString();
                    final String date = rawDate.split('T')[0]; // Ambil YYYY-MM-DD saja

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_add, color: Colors.green),
                        ),
                        title: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black, fontSize: 14),
                            children: [
                              const TextSpan(text: "RT Baru Terdaftar: "),
                              TextSpan(
                                text: "RT ${item['kode_rt']}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("Ketua: ${item['nama_ketua']}"),
                            Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}