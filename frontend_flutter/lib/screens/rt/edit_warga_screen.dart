import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EditWargaScreen extends StatefulWidget {
  final Map<String, dynamic> data; // Data lama untuk diisi ke form

  const EditWargaScreen({super.key, required this.data});

  @override
  State<EditWargaScreen> createState() => _EditWargaScreenState();
}

class _EditWargaScreenState extends State<EditWargaScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller
  late TextEditingController _namaController;
  late TextEditingController _nikController;
  late TextEditingController _kkController;
  late TextEditingController _emailController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Isi form dengan data lama saat halaman dibuka
    _namaController = TextEditingController(text: widget.data['nama_lengkap']);
    _nikController = TextEditingController(text: widget.data['nik']);
    _kkController = TextEditingController(text: widget.data['no_kk']);
    _emailController = TextEditingController(text: widget.data['email']);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _kkController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Siapkan data yang mau diupdate
    final Map<String, dynamic> newData = {
      "nama_lengkap": _namaController.text,
      "nik": _nikController.text,
      "no_kk": _kkController.text,
      "email": _emailController.text,
      // Tambahkan field lain jika perlu (misal tanggal lahir)
    };

    final int idWarga = widget.data['id_warga'];

    // Panggil API
    bool success = await ApiService.editWarga(idWarga, newData);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil diperbarui! ✅"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Kembali ke detail & refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mengupdate data"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Background Cream
      appBar: AppBar(
        title: const Text("Edit Data Warga", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInput("Nama Lengkap", _namaController),
              _buildInput("NIK", _nikController, isNumber: true),
              _buildInput("No. Kartu Keluarga", _kkController, isNumber: true),
              _buildInput("Email", _emailController, isEmail: true),
              
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleSave,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: _isLoading 
                      ? const Text("Menyimpan...", style: TextStyle(color: Colors.white)) 
                      : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {bool isNumber = false, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        validator: (value) => value!.isEmpty ? "$label tidak boleh kosong" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}