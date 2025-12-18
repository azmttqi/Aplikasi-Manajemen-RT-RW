import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StatistikPerRtScreen extends StatefulWidget {
  final String title;
  final String dataType; // 'warga' atau 'kk'

  const StatistikPerRtScreen({super.key, required this.title, required this.dataType});

  @override
  State<StatistikPerRtScreen> createState() => _StatistikPerRtScreenState();
}

class _StatistikPerRtScreenState extends State<StatistikPerRtScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _fullData;
  bool get _isWargaMode => widget.dataType == 'warga';

  @override
  void initState() {
    super.initState();
    _fetchLengkap();
  }

  Future<void> _fetchLengkap() async {
    final result = await ApiService.getStatistikRWLengkap();
    if (mounted) {
      setState(() {
        _fullData = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    final summary = _fullData?['summary'];
    final rtList = _fullData?['rt_list'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E5),
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER SUMMARY ---
            Text(_isWargaMode ? "Ringkasan Demografi Se-RW" : "Ringkasan Keluarga Se-RW", 
                 style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            _isWargaMode ? _buildWargaHeader(summary) : _buildKKHeader(summary),

            const SizedBox(height: 30),
            Text(_isWargaMode ? "Rincian Warga Per RT" : "Rincian KK Per RT", 
                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFD36F00))),
            const SizedBox(height: 15),

            // --- LIST RT ---
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rtList.length,
              itemBuilder: (context, index) {
                final rt = rtList[index];
                return _buildRTCard(rt);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildWargaHeader(dynamic data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryItem(data?['pria'], "Pria", Icons.male, Colors.blue),
              _summaryItem(data?['wanita'], "Wanita", Icons.female, Colors.pink),
            ],
          ),
          const Divider(height: 30),
          _ageGrid(data),
        ],
      ),
    );
  }

  Widget _buildKKHeader(dynamic data) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(Icons.folder_shared, color: Colors.green, size: 40),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Total Kartu Keluarga", style: TextStyle(color: Colors.grey)),
              Text("${data?['total_kk'] ?? 0}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRTCard(dynamic rt) {
    final count = _isWargaMode ? rt['total_warga'] : rt['total_kk'];
    final label = _isWargaMode ? "Jiwa" : "KK";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: () => _isWargaMode ? _showDetailRT(rt) : null,
        leading: CircleAvatar(backgroundColor: Colors.orange.shade50, child: Text(rt['nomor_rt'].toString(), style: const TextStyle(color: Colors.orange))),
        title: Text("RT ${rt['nomor_rt']}"),
        trailing: Text("$count $label", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
      ),
    );
  }

  // --- POPUP DETAIL RT ---
  void _showDetailRT(Map<String, dynamic> rt) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Statistik RT ${rt['nomor_rt']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _rowInfo("Laki-laki", "${rt['pria']}", Icons.male, Colors.blue),
            _rowInfo("Perempuan", "${rt['wanita']}", Icons.female, Colors.pink),
            const SizedBox(height: 15),
            _ageGrid(rt),
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---
  BoxDecoration _cardDecoration() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]);

  Widget _summaryItem(dynamic count, String label, IconData icon, Color color) {
    return Flexible( // Fix Overflow
      child: Column(
        children: [
          Icon(icon, color: color),
          Text("${count ?? 0}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _ageGrid(dynamic data) {
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: [
        _ageBox("Lansia", data?['lansia'], Colors.orange),
        _ageBox("Dewasa", data?['dewasa'], Colors.teal),
        _ageBox("Remaja", data?['remaja'], Colors.indigo),
        _ageBox("Anak", data?['anak'], Colors.redAccent),
      ],
    );
  }

  Widget _ageBox(String label, dynamic count, Color color) {
    return Container(
      width: 70, padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [Text("${count ?? 0}", style: TextStyle(fontWeight: FontWeight.bold, color: color)), Text(label, style: TextStyle(fontSize: 10, color: color))]),
    );
  }

  Widget _rowInfo(String label, String value, IconData icon, Color color) {
    return Row(children: [Icon(icon, color: color), const SizedBox(width: 10), Text(label), const Spacer(), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]);
  }
}