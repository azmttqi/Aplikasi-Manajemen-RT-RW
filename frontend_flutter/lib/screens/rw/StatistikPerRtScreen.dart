import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StatistikPerRtScreen extends StatefulWidget {
  final String title; // Judul Halaman
  final String dataType; // 'warga' atau 'kk'

  const StatistikPerRtScreen({
    super.key, 
    required this.title, 
    required this.dataType
  });

  @override
  State<StatistikPerRtScreen> createState() => _StatistikPerRtScreenState();
}

class _StatistikPerRtScreenState extends State<StatistikPerRtScreen> {
  bool _isLoading = true;
  List<dynamic> _dataList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Kita pakai API getWargaList yang sudah ada (karena sekarang sudah bawa data jumlah)
      final result = await ApiService.getWargaList();
      if (mounted) {
        setState(() {
          _dataList = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFFAF6E6),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _dataList.length,
              itemBuilder: (context, index) {
                final item = _dataList[index];
                final String nomorRt = item['nomor_rt'] ?? '-';
                
                // Pilih data yang mau ditampilkan sesuai dataType
                final String jumlah = widget.dataType == 'warga'
                    ? (item['jumlah_warga'] ?? '0').toString()
                    : (item['jumlah_kk'] ?? '0').toString();

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50], 
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: const Icon(Icons.analytics, color: Colors.blue),
                    ),
                    title: Text("RT $nomorRt", style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "$jumlah ${widget.dataType == 'warga' ? 'Jiwa' : 'KK'}",
                        style: TextStyle(
                          color: Colors.green[800], 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}