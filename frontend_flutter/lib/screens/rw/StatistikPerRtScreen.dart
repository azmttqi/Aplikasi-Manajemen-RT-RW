import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StatistikPerRtScreen extends StatefulWidget {
  final String title;     // Judul Halaman (misal: "Sebaran Warga per RT")
  final String dataType;  // Tipe Data: 'warga' atau 'kk'

  const StatistikPerRtScreen({
    super.key,
    required this.title,
    required this.dataType,
  });

  @override
  State<StatistikPerRtScreen> createState() => _StatistikPerRtScreenState();
}

class _StatistikPerRtScreenState extends State<StatistikPerRtScreen> {
  bool _isLoading = true;
  List<dynamic> _listRtData = [];
  String? _errorMessage;

  // Variabel helper untuk membedakan mode Warga atau KK
  bool get _isWargaMode => widget.dataType == 'warga';

  @override
  void initState() {
    super.initState();
    _fetchRtData();
  }

  Future<void> _fetchRtData() async {
    try {
      // Menggunakan endpoint yang sama (getStatistikPerRt) 
      // Pastikan Backend mengirimkan object lengkap: {total_warga, total_kk, gender, dll}
      final data = await ApiService.getStatistikPerRt();
      
      if (mounted) {
        setState(() {
          _listRtData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Gagal memuat data: $e";
        });
      }
    }
  }

  // --- FUNGSI POPUP GENDER (Khusus Mode Warga) ---
  void _showGenderPopup(BuildContext context, String rtName, int laki, int perempuan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              
              Text("Statistik Gender RT $rtName", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text("Detail persebaran gender di RT ini.", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 20),
              
              _detailItem("Laki-laki", "$laki Jiwa", Icons.male, Colors.blue),
              const SizedBox(height: 10),
              _detailItem("Perempuan", "$perempuan Jiwa", Icons.female, Colors.pink),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // --- FUNGSI POPUP KK (Khusus Mode KK - Sederhana) ---
  void _showKkPopup(BuildContext context, String rtName, int count) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              
              Text("Info KK - RT $rtName", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              _detailItem("Total KK", "$count Kepala Keluarga", Icons.card_membership, Colors.green),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Widget Item Baris untuk Popup
  Widget _detailItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [Icon(icon, color: color), const SizedBox(width: 15), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold))]),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan Warna Tema berdasarkan Tipe Data
    final Color themeColor = _isWargaMode ? Colors.blue : Colors.green;
    final IconData themeIcon = _isWargaMode ? Icons.people : Icons.folder_shared;

    // Hitung Total Keseluruhan (Grand Total) dari list yang didapat
    int grandTotal = 0;
    if (!_isLoading && _listRtData.isNotEmpty) {
      grandTotal = _listRtData.fold(0, (sum, item) {
        final key = _isWargaMode ? 'total_warga' : 'total_kk';
        // Pastikan parsing aman
        final val = int.tryParse(item[key]?.toString() ?? '0') ?? 0;
        return sum + val;
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E5), // Background Cream
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // --- 1. HEADER RINGKASAN (Grand Total) ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(themeIcon, color: themeColor, size: 30),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total ${widget.dataType == 'warga' ? 'Warga' : 'KK'} Se-RW", 
                        style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 5),
                      _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(
                            "$grandTotal", 
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text("Rincian Per RT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD36F00))),
          ),
          const SizedBox(height: 10),

          // --- 2. LIST DATA PER RT ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null 
                    ? Center(child: Text(_errorMessage!))
                    : _listRtData.isEmpty
                        ? const Center(child: Text("Belum ada data RT"))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: _listRtData.length,
                            itemBuilder: (context, index) {
                              final rt = _listRtData[index];
                              
                              // Tentukan Key JSON mana yang mau diambil
                              final dataKey = _isWargaMode ? 'total_warga' : 'total_kk';
                              final countValue = rt[dataKey]?.toString() ?? '0';

                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFFD36F00).withOpacity(0.1),
                                    child: Text(
                                      rt['nomor_rt'].toString(), 
                                      style: const TextStyle(color: Color(0xFFD36F00), fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                  title: Text("RT ${rt['nomor_rt']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  
                                  // Menampilkan Jumlah Warga atau KK
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: themeColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "$countValue ${_isWargaMode ? 'Jiwa' : 'KK'}",
                                      style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  
                                  onTap: () {
                                    // LOGIKA KLIK BERDASARKAN TIPE DATA
                                    if (_isWargaMode) {
                                      // Jika Mode Warga -> Tampilkan Popup Gender
                                      final genderRt = rt['gender'] ?? {};
                                      final int lakiRt = int.tryParse(genderRt['laki']?.toString() ?? '0') ?? 0;
                                      final int prRt = int.tryParse(genderRt['perempuan']?.toString() ?? '0') ?? 0;
                                      
                                      _showGenderPopup(context, rt['nomor_rt'].toString(), lakiRt, prRt);
                                    } else {
                                      // Jika Mode KK -> Tampilkan Info Sederhana (atau Popup KK)
                                      final int totalKK = int.tryParse(countValue) ?? 0;
                                      _showKkPopup(context, rt['nomor_rt'].toString(), totalKK);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}