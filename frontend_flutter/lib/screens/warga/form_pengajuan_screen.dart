import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class FormPengajuanScreen extends StatefulWidget {
  const FormPengajuanScreen({super.key});

  @override
  State<FormPengajuanScreen> createState() => _FormPengajuanScreenState();
}

class _FormPengajuanScreenState extends State<FormPengajuanScreen> {
  // Controller
  final _namaBaruController = TextEditingController();
  final _tglLahirBaruController = TextEditingController();
  final _alasanController = TextEditingController();
  
  // Data Lama (Placeholder, nanti bisa ambil dari API getMe)
  String _oldNama = "...";
  String _oldTgl = "...";
  String _oldHp = "...";
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() async {
    final profil = await ApiService.getMe();
    if (mounted && profil != null) {
      setState(() {
        _oldNama = profil['nama_lengkap'] ?? "-";
        _oldTgl = profil['tanggal_lahir'] ?? "-";
        _oldHp = profil['no_hp'] ?? "-"; // Pastikan backend kirim no_hp jika ada
      });
    }
  }

  void _kirimPengajuan() async {
    if (_alasanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mohon isi alasan perubahan")));
      return;
    }

    setState(() => _isLoading = true);

    // Kita gabungkan data menjadi satu string keterangan
    String keterangan = "Pengajuan Ubah Data:\n"
        "Nama Baru: ${_namaBaruController.text}\n"
        "Tgl Lahir Baru: ${_tglLahirBaruController.text}\n"
        "Alasan: ${_alasanController.text}";

    bool success = await ApiService.ajukanPerubahan(keterangan);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pengajuan terkirim! ✅"), backgroundColor: Colors.green));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mengirim pengajuan"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6E6),
      appBar: AppBar(
        title: const Text("Pengajuan Perubahan Data", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KARTU DATA LAMA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Data Lama Anda", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("Nama Lengkap : $_oldNama"),
                  Text("Tanggal Lahir : $_oldTgl"),
                  Text("No. Handphone : $_oldHp"),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // FORM INPUT
            _buildInput("Nama Lengkap (Sesuai KTP)", _namaBaruController),
            _buildInput("Tanggal Lahir", _tglLahirBaruController, isDate: true),
            
            const SizedBox(height: 20),
            const Text("Ajukan Data Baru", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            _buildInput("Alasan Perubahan (Opsional)", _alasanController, maxLines: 3),
            
            const SizedBox(height: 20),
            
            // TOMBOL KIRIM
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _kirimPengajuan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Hijau
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Ajukan Perubahan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController controller, {bool isDate = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: isDate,
        onTap: isDate ? () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            controller.text = "${picked.day}-${picked.month}-${picked.year}";
          }
        } : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade400)),
          suffixIcon: isDate ? const Icon(Icons.calendar_today, size: 20, color: Colors.grey) : null,
        ),
      ),
    );
  }
}