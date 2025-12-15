import 'package:flutter/material.dart';
import '../../services/api_service.dart';
// Jika ingin format tanggal rapi, bisa tambahkan package intl di pubspec.yaml
// import 'package:intl/intl.dart'; 

class WargaNotificationScreen extends StatefulWidget {
  const WargaNotificationScreen({super.key});

  @override
  State<WargaNotificationScreen> createState() => _WargaNotificationScreenState();
}

class _WargaNotificationScreenState extends State<WargaNotificationScreen> {
  bool _isLoading = true;
  List<dynamic> _notifList = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotifikasi();
  }

  // Fungsi Ambil Data dari API
  Future<void> _fetchNotifikasi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Panggil API (Pastikan fungsi getNotifikasiWarga sudah ada di ApiService)
      final data = await ApiService.getNotifikasiWarga();
      
      if (mounted) {
        setState(() {
          _notifList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Gagal memuat notifikasi. Cek koneksi.";
          // Data dummy dihapus agar tidak membingungkan
          _notifList = []; 
        });
        print("Error fetching notif: $e");
      }
    }
  }

  // Helper format tanggal sederhana
  String _formatDate(String? dateString) {
    if (dateString == null) return "Baru saja";
    try {
      DateTime date = DateTime.parse(dateString).toLocal();
      // Format manual: DD/MM/YYYY HH:MM
      return "${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year} "
             "${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}";
    } catch (e) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Cream Background (Sama sengan file lama)
      appBar: AppBar(
        title: const Text(
          "Notifikasi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Hapus tombol back (sesuai file lama)
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.green),
            tooltip: "Refresh Data",
            onPressed: _fetchNotifikasi,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _notifList.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _fetchNotifikasi,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(15),
                        itemCount: _notifList.length,
                        itemBuilder: (context, index) {
                          final item = _notifList[index];
                          return _buildNotificationCard(item);
                        },
                      ),
                    ),
    );
  }

  // Widget Kartu Notifikasi (Desain Dipertahankan)
  Widget _buildNotificationCard(Map<String, dynamic> item) {
    final status = item['status'] ?? 'unknown';
    final keterangan = item['keterangan'] ?? 'Perubahan Data';
    final dateStr = item['updated_at'] ?? item['created_at'];
    
    // Logika Tampilan Berdasarkan Status
    bool isApproved = (status == 'disetujui');
    
    Color iconColor;
    IconData iconData;
    String title;
    String body;

    if (isApproved) {
      iconColor = Colors.green;
      iconData = Icons.check_circle_outline;
      title = "Pengajuan Disetujui";
      body = "Selamat! Pengajuan perubahan data '$keterangan' Anda telah disetujui oleh Ketua RT.";
    } else {
      iconColor = Colors.red; // Merah untuk ditolak (Ganti dari oranye alert dummy)
      iconData = Icons.cancel_outlined;
      title = "Pengajuan Ditolak";
      body = "Maaf, pengajuan perubahan data '$keterangan' Anda ditolak. Silakan hubungi RT.";
    }

    // Border berwarna jika belum dibaca (Logic simulasi karena API belum support isRead)
    // Kita anggap notifikasi baru (kurang dari 24 jam) diberi highlight
    bool highlight = false; 
    try {
        if(dateStr != null) {
            final date = DateTime.parse(dateStr);
            if(DateTime.now().difference(date).inHours < 24) highlight = true;
        }
    } catch(e){}


    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: highlight
            ? Border.all(color: iconColor.withOpacity(0.5), width: 1.5)
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Bulat
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 15),
          
          // Konten Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: highlight ? Colors.black : Colors.black87,
                        ),
                      ),
                    ),
                    if (highlight)
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(body, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 8),
                Text(_formatDate(dateStr), style: TextStyle(color: Colors.grey[400], fontSize: 10)),
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
          const SizedBox(height: 16),
          Text("Belum ada notifikasi", style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 10),
          Text(_errorMessage ?? "Terjadi Kesalahan"),
          TextButton(onPressed: _fetchNotifikasi, child: const Text("Coba Lagi"))
        ],
      ),
    );
  }
}