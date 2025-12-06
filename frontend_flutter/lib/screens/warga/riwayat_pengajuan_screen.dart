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
    _loadData();
  }

  void _loadData() async {
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
      appBar: AppBar(title: const Text("Riwayat Pengajuan"), backgroundColor: Colors.green, foregroundColor: Colors.white),
      backgroundColor: const Color(0xFFFAF6E6),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? const Center(child: Text("Belum ada pengajuan"))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: _list.length,
                  itemBuilder: (context, index) {
                    final item = _list[index];
                    String status = (item['status'] ?? 'pending').toUpperCase();
                    Color color = Colors.orange;
                    if (status == 'DISETUJUI') color = Colors.green;
                    if (status == 'DITOLAK') color = Colors.red;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(item['keterangan'] ?? "-", maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text(item['created_at']?.split('T')[0] ?? "-"),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: color),
                          ),
                          child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}