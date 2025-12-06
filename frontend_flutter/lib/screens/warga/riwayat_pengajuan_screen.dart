import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RiwayatPengajuanScreen extends StatefulWidget {
  const RiwayatPengajuanScreen({super.key});

  @override
  State<RiwayatPengajuanScreen> createState() => _RiwayatPengajuanScreenState();
}

class _RiwayatPengajuanScreenState extends State<RiwayatPengajuanScreen> {
  List<dynamic> _list = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final data = await ApiService.getRiwayatPengajuan();
    if (mounted) {
      setState(() {
        _list = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6E6),
      appBar: AppBar(
        title: const Text("Riwayat Pengajuan", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? const Center(child: Text("Belum ada riwayat pengajuan"))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _list.length,
                  itemBuilder: (context, index) {
                    final item = _list[index];
                    
                    // Status Style
                    String status = (item['status'] ?? 'pending').toString().toUpperCase();
                    Color statusColor = Colors.orange;
                    if (status == 'DISETUJUI') statusColor = Colors.green;
                    if (status == 'DITOLAK') statusColor = Colors.red;

                    // Tanggal
                    String date = item['created_at']?.split('T')[0] ?? "-";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: statusColor),
                                  ),
                                  child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text("Detail Perubahan:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 5),
                            Text(item['keterangan'] ?? "-", style: const TextStyle(fontSize: 14)),
                            
                            if (item['catatan_rt'] != null) ...[
                              const Divider(height: 20),
                              Text("Catatan RT: ${item['catatan_rt']}", style: TextStyle(color: Colors.red[800], fontSize: 12, fontStyle: FontStyle.italic)),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}