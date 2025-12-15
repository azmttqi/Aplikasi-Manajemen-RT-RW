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

  // Variabel penampung data
  List<dynamic> _newRegistrations = [];
  List<dynamic> _dataUpdates = [];
  List<dynamic> _rejectedList = []; // <--- LIST BARU (DITOLAK)

  @override
  void initState() {
    super.initState();
    // UBAH LENGTH JADI 3 (Verifikasi, Update, Ditolak)
    _tabController = TabController(length: 3, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    
    // Pastikan ApiService.getRtNotifications() kamu sudah mengembalikan 3 key
    // (pendaftaran_baru, pengajuan_update, warga_ditolak) sesuai panduan sebelumnya.
    final result = await ApiService.getRtNotifications();
    
    if (mounted) {
      setState(() {
        if (result != null) {
          _newRegistrations = result['pendaftaran_baru'] ?? [];
          _dataUpdates = result['pengajuan_update'] ?? [];
          _rejectedList = result['warga_ditolak'] ?? []; // <--- AMBIL DATA DITOLAK
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
      backgroundColor: const Color(0xFFF8F2E5), // Warna asli kamu
      appBar: AppBar(
        title: const Text("Permohonan Warga", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        // centerTitle: true, // Biar judul pas di tengah
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold), // Teks aktif tebal
          unselectedLabelColor: Colors.grey,
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          indicatorColor: Colors.green,
          indicatorWeight: 3, // Ketebalan garis
          indicatorSize: TabBarIndicatorSize.tab, // <--- PENTING: Garis selebar kotak tab
          // isScrollable: false, // Defaultnya false, jadi akan memenuhi lebar layar (Rapi)
          tabs: const [
            Tab(text: "Verifikasi"), 
            Tab(text: "Update"),     
            Tab(text: "Ditolak"),    
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: PENDAFTARAN BARU
              RefreshIndicator(
                onRefresh: _onRefresh,
                child: _buildRegistrationList(),
              ),
              // TAB 2: UPDATE DATA
              RefreshIndicator(
                onRefresh: _onRefresh,
                child: _buildUpdateDataList(),
              ),
              // TAB 3: DITOLAK (RECYCLE BIN)
              RefreshIndicator(
                onRefresh: _onRefresh,
                child: _buildRejectedList(),
              ),
            ],
          ),
    );
  }

  // --- BUILDER LIST MASING-MASING TAB ---

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
          isRejectedTab: false, // Bukan tab ditolak
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
          isRejectedTab: false, // Bukan tab ditolak
        );
      },
    );
  }

  // WIDGET BARU: LIST DITOLAK
  Widget _buildRejectedList() {
    if (_rejectedList.isEmpty) return _emptyState("Keranjang sampah kosong");
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _rejectedList.length,
      itemBuilder: (context, index) {
        final item = _rejectedList[index];
        return _buildCard(
          title: item['nama_lengkap'] ?? "Tanpa Nama",
          subtitle: "Ditolak pada: ${item['created_at'] ?? '-'}",
          time: "Ketuk icon panah putar untuk pulihkan",
          status: "Ditolak",
          icon: Icons.block,
          color: Colors.red,
          itemData: item,
          isRegistration: true, // Tetap dianggap regis agar logic ID jalan
          isRejectedTab: true, // <--- INI PENTING
        );
      },
    );
  }

  // --- COMPONENT CARD (MODIFIKASI DIKIT UNTUK TOMBOL RESTORE) ---

  Widget _buildCard({
    required String title,
    required String subtitle,
    required String time,
    required String status,
    required IconData icon,
    required Color color,
    required Map<String, dynamic> itemData,
    required bool isRegistration,
    required bool isRejectedTab, // Parameter baru
  }) {
    // Logic warna badge (Sama kayak punya kamu)
    String statusLower = status.toLowerCase(); 
    bool isPending = statusLower == 'menunggu' || statusLower == 'pending';
    bool isRejected = statusLower == 'ditolak' || statusLower == 'rejected';

    Color statusColor = Colors.grey;
    if (isPending) statusColor = Colors.orange;
    if (isRejected) statusColor = Colors.red; // Merah kalau ditolak

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
        
        // --- MODIFIKASI TRAILING (KANAN) ---
        // Jika Tab Ditolak: Tampilkan Tombol Restore (Panah Hijau)
        // Jika Tab Biasa: Tampilkan Badge Status
        trailing: isRejectedTab 
          ? IconButton(
              icon: const Icon(Icons.restore_page, color: Colors.green, size: 30),
              tooltip: "Pulihkan Warga",
              onPressed: () => _showRestoreDialog(itemData),
            )
          : Container(
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
            
        // Klik Card hanya aktif jika Pending (bukan di tab ditolak)
        onTap: (!isRejectedTab && isPending) 
            ? () => _showActionDialog(itemData, isRegistration) 
            : null,
      ),
    );
  }

  // --- LOGIKA RESTORE (PULIHKAN) ---
  void _showRestoreDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Pulihkan Warga?"),
        content: Text("Warga '${item['nama_lengkap']}' akan dikembalikan statusnya menjadi 'Menunggu' dan muncul kembali di tab Verifikasi Akun."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Batal", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);

              // Ambil ID
              var rawId = item['id'] ?? item['id_warga'];
              int idWarga = int.tryParse(rawId.toString()) ?? 0;

              // Panggil API verify dengan status 'pending' (Reset)
              bool success = await ApiService.verifyWargaBaru(idWarga, 'pending');

              if (mounted) {
                if (success) {
                  _fetchData(); // Refresh Data
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Warga berhasil dipulihkan! ♻️"), backgroundColor: Colors.green)
                  );
                } else {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Gagal memulihkan data"), backgroundColor: Colors.red)
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            icon: const Icon(Icons.restore, color: Colors.white, size: 18),
            label: const Text("Ya, Pulihkan", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // --- DIALOG AKSI LAMA (Tetap dipakai untuk Tab 1 & 2) ---
  void _showActionDialog(Map<String, dynamic> item, bool isRegistration) {
    bool isProcessing = false;

    var rawId = item['id'] ?? item['id_warga'] ?? item['id_pengajuan']; 
    int idItem = int.tryParse(rawId.toString()) ?? 0;

    String nama = item['nama_lengkap'] ?? item['nama'] ?? "Tanpa Nama";
    String alamat = item['alamat'] ?? "-";
    String nik = item['nik'] ?? "-";
    String noKk = item['no_kk'] ?? "-";
    String keterangan = item['keterangan'] ?? "-";

    if (idItem == 0) return;

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
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ditolak ❌. Masuk ke tab Riwayat.")));
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