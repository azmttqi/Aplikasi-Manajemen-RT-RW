import 'package:flutter/material.dart';
import '../../services/api_service.dart'; 

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Variabel penampung data asli
  List<dynamic> _newRegistrations = [];
  List<dynamic> _dataUpdates = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData(); 
  }

  // FUNGSI TARIK DATA DARI API
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    
    final result = await ApiService.getRtNotifications();
    
    if (mounted) {
      setState(() {
        if (result != null) {
          _newRegistrations = result['pendaftaran_baru'] ?? [];
          _dataUpdates = result['pengajuan_update'] ?? [];
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E5),
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
            Tab(text: "Verifikasi Akun"),
            Tab(text: "Update Data"),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : TabBarView(
            controller: _tabController,
            children: [
              RefreshIndicator(
                onRefresh: _onRefresh,
                child: _buildRegistrationList(),
              ),
              RefreshIndicator(
                onRefresh: _onRefresh,
                child: _buildUpdateDataList(),
              ),
            ],
          ),
    );
  }

  Widget _buildRegistrationList() {
    if (_newRegistrations.isEmpty) return _emptyState("Tidak ada pendaftaran baru");
    
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _newRegistrations.length,
      itemBuilder: (context, index) {
        final item = _newRegistrations[index];
        return _buildCard(
          title: item['nama_lengkap'] ?? "Tanpa Nama",
          subtitle: "Daftar Warga Baru • ${item['alamat'] ?? '-'}",
          time: item['created_at'] ?? "-", 
          status: item['status_verifikasi'] ?? "Menunggu", 
          icon: Icons.person_add,
          color: Colors.blue,
          itemData: item,
          isRegistration: true,
        );
      },
    );
  }

  Widget _buildUpdateDataList() {
    if (_dataUpdates.isEmpty) return _emptyState("Tidak ada pengajuan data");

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _dataUpdates.length,
      itemBuilder: (context, index) {
        final item = _dataUpdates[index];
        return _buildCard(
          title: item['nama_lengkap'] ?? "Tanpa Nama",
          subtitle: "Pengajuan: ${item['keterangan'] ?? 'Ubah Data'}",
          time: item['created_at'] ?? "-",
          status: item['status_pengajuan'] ?? "Menunggu",
          icon: Icons.edit_document,
          color: Colors.orange,
          itemData: item,
          isRegistration: false,
        );
      },
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required String time,
    required String status,
    required IconData icon,
    required Color color,
    required Map<String, dynamic> itemData,
    required bool isRegistration,
  }) {
    // 1. Normalisasi Status
    String statusLower = status.toLowerCase(); 
    bool isPending = statusLower == 'menunggu' || statusLower == 'pending';
    bool isApproved = statusLower == 'disetujui' || statusLower == 'approved';
    bool isRejected = statusLower == 'ditolak' || statusLower == 'rejected';

    // 2. Warna Badge
    Color statusColor = Colors.grey;
    if (isPending) statusColor = Colors.orange;
    if (isApproved) statusColor = Colors.green;
    if (isRejected) statusColor = Colors.red;

    // 3. Teks Tampilan
    String displayStatus = status;
    if (isPending) displayStatus = "Menunggu";
    if (isApproved) displayStatus = "Disetujui";
    if (isRejected) displayStatus = "Ditolak";

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            Text(subtitle, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 5),
            Text(time, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
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
            displayStatus,
            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        // Hanya bisa diklik jika statusnya PENDING
        onTap: isPending 
            ? () => _showActionDialog(itemData, isRegistration) 
            : null,
      ),
    );
  }

  // DIALOG AKSI (VERSI FIX ANTI CRASH)
// GANTI FUNGSI INI DI DALAM notification_screen.dart

  void _showActionDialog(Map<String, dynamic> item, bool isRegistration) {
    bool isProcessing = false;

    // --- DEBUGGING: CEK ISI DATA DI CONSOLE ---
    print("DATA YANG DIKLIK: $item"); 

    // 1. CARI ID DENGAN CERDAS
    // Cek apakah key-nya 'id' ATAU 'id_warga'
    var rawId = item['id'] ?? item['id_warga']; 
    int idItem = int.tryParse(rawId.toString()) ?? 0;

    print("ID YANG DITEMUKAN: $idItem"); // Pastikan ini BUKAN 0

    // Ambil data lain (String)
    String nama = item['nama_lengkap'] ?? item['nama'] ?? "Tanpa Nama";
    String alamat = item['alamat'] ?? "-";
    String nik = item['nik'] ?? "-";
    String noKk = item['no_kk'] ?? "-";
    String keterangan = item['keterangan'] ?? "-";

    if (idItem == 0) {
      // Jika ID masih 0, tampilkan error dan jangan buka dialog aksi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ID Warga tidak ditemukan di data ($item)")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isRegistration ? "Verifikasi Akun" : "Perubahan Data"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow("Nama", nama),
                    const SizedBox(height: 10),
                    if (isRegistration) ...[
                      _detailRow("NIK", nik),
                      _detailRow("No KK", noKk),
                      _detailRow("Alamat", alamat),
                    ] else ...[
                      _detailRow("Perubahan", keterangan),
                    ],
                    const SizedBox(height: 20),
                    const Text("Tindakan:", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isProcessing ? null : () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                
                // TOMBOL TOLAK
                OutlinedButton(
                  onPressed: isProcessing ? null : () async {
                    setStateDialog(() => isProcessing = true);
                    bool success;
                    
                    if (isRegistration) {
                      success = await ApiService.verifyWargaBaru(idItem, 'ditolak');
                    } else {
                      success = await ApiService.verifyUpdateData(idItem, 'ditolak');
                    }

                    if (mounted) {
                      Navigator.pop(context);
                      if (success) {
                        _fetchData(); 
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ditolak ❌")));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal memproses")));
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: isProcessing 
                      ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : const Text("Tolak"),
                ),

                // TOMBOL SETUJUI
                ElevatedButton(
                  onPressed: isProcessing ? null : () async {
                    setStateDialog(() => isProcessing = true);
                    bool success;
                    
                    if (isRegistration) {
                      success = await ApiService.verifyWargaBaru(idItem, 'disetujui');
                    } else {
                      success = await ApiService.verifyUpdateData(idItem, 'disetujui');
                    }

                    if (mounted) {
                      Navigator.pop(context);
                      if (success) {
                        _fetchData(); 
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Disetujui ✅"), backgroundColor: Colors.green));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal memproses"), backgroundColor: Colors.red));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: isProcessing 
                      ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Text("Setujui", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))),
          const Text(": ", style: TextStyle(color: Colors.grey, fontSize: 12)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  // --- INI DIA FUNGSI YANG HILANG ---
  Widget _emptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}