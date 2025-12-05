import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'verify_detail_screen.dart'; // ✅ Import halaman detail

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _wargaList = [];
  bool _isLoading = false;
  String _rtName = "RT ..."; 

  @override
  void initState() {
    super.initState();
    _fetchWarga(); 
    _getProfileInfo();
  }

  void _getProfileInfo() async {
    final me = await ApiService.getMe();
    if (me != null && mounted) {
      setState(() {
        _rtName = me['nomor_wilayah'] ?? "RT ...";
      });
    }
  }

  void _fetchWarga([String? query]) async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getWargaList(query: query ?? '');
      if (mounted) {
        setState(() {
          _wargaList = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _maskNik(String? nik) {
    if (nik == null || nik.length < 5) return "xxxxxxxx";
    return "${nik.substring(0, 5)}xxxxxxxx";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), 
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- HEADER ---
            const Icon(Icons.home_work_rounded, size: 50, color: Colors.green),
            const Text(
              "Manajemen RT/RW",
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "Pencarian Data Warga - $_rtName",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 20),

            // --- SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: "Cari NIK atau Nama Warga",
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                          prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (value) => _fetchWarga(value),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _fetchWarga(_searchController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text("Cari", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- TABEL HEADER ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF6B8E78), 
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: Text("NIK (Samaran)", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                  Expanded(flex: 3, child: Text("Nama Lengkap", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text("Aksi", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                ],
              ),
            ),

            // --- LIST DATA ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _wargaList.isEmpty
                      ? const Center(child: Text("Tidak ada data warga ditemukan."))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _wargaList.length,
                          itemBuilder: (context, index) {
                            final warga = _wargaList[index];
                            
                            // Cek Status untuk pewarnaan
                            String status = (warga['status_verifikasi'] ?? 'pending').toString().toLowerCase();
                            Color statusColor = Colors.grey;
                            if (status == 'disetujui') statusColor = Colors.green;
                            if (status == 'ditolak') statusColor = Colors.red;
                            if (status == 'pending') statusColor = Colors.orange;

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey.shade300),
                                  left: BorderSide(color: statusColor, width: 4), // Garis warna status di kiri
                                  right: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
                              child: Row(
                                children: [
                                  // Kolom 1: NIK
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      _maskNik(warga['nik']),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  // Kolom 2: Nama
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      warga['nama_lengkap'] ?? "-",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  // Kolom 3: Tombol Detail
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: SizedBox(
                                        height: 25,
                                        width: 60,
                                        child: ElevatedButton(
                                          // ✅ NAVIGASI KE DETAIL SCREEN
                                          onPressed: () async {
                                            // Kita reuse halaman VerifyDetailScreen karena fungsinya sama
                                            // (Melihat detail & Mengubah status)
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => VerifyDetailScreen(data: warga),
                                              ),
                                            );

                                            // Jika ada perubahan di dalam detail, refresh list pencarian
                                            if (result == true) {
                                              _fetchWarga(_searchController.text);
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF9FA8DA), 
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                          ),
                                          child: const Text("Detail", style: TextStyle(fontSize: 10, color: Colors.black)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}