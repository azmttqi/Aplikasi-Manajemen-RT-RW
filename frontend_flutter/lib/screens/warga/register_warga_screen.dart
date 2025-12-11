import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../widgets/logo_widget.dart'; // Import Logo Widget

// === HALAMAN 1: DATA DIRI ===
class RegisterWargaStep1 extends StatefulWidget {
  const RegisterWargaStep1({super.key});

  @override
  State<RegisterWargaStep1> createState() => _RegisterWargaStep1State();
}

class _RegisterWargaStep1State extends State<RegisterWargaStep1> {
  final _nikController = TextEditingController();
  final _kkController = TextEditingController();
  final _namaController = TextEditingController();
  final _tglLahirController = TextEditingController();

  // Fungsi pilih tanggal
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tglLahirController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _goToStep2() {
    if (_nikController.text.isEmpty || _namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("NIK dan Nama wajib diisi!")));
      return;
    }

    // Pindah ke Halaman 2 sambil bawa data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterWargaStep2(
          nik: _nikController.text,
          noKk: _kkController.text,
          nama: _namaController.text,
          tglLahir: _tglLahirController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBE6), // Cream background
      appBar: AppBar(
        title: const Text("Pendaftaran Akun Warga (1/2)"), 
        backgroundColor: Colors.transparent, 
        foregroundColor: Colors.black, 
        elevation: 0
      ),
      body: SingleChildScrollView( // Tambahkan SingleChildScrollView agar aman di layar kecil
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              
              // --- 1. LOGO BARU DI STEP 1 ---
              const Center(
                child: LogoWidget(height: 180, width: 180),
              ),
              const SizedBox(height: 30),
              // ------------------------------

              _buildInputBox("Nomor Induk Kependudukan (NIK)", _nikController, isNumber: true),
              _buildInputBox("Nomor Kartu Keluarga", _kkController, isNumber: true),
              _buildInputBox("Nama Lengkap (Sesuai KTP)", _namaController),
              
              // Input Tanggal Lahir + Icon Calendar
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: TextField(
                    controller: _tglLahirController,
                    decoration: InputDecoration(
                      labelText: "Tanggal Lahir",
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true, fillColor: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goToStep2,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF678267), // Hijau (Tema Logo)
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15)
                  ),
                  child: const Text("Lanjut", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBox(String hint, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true, fillColor: Colors.white,
        ),
      ),
    );
  }
}

// === HALAMAN 2: AKUN & KODE ===
class RegisterWargaStep2 extends StatefulWidget {
  final String nik, noKk, nama, tglLahir;

  const RegisterWargaStep2({
    super.key, 
    required this.nik, 
    required this.noKk, 
    required this.nama, 
    required this.tglLahir
  });

  @override
  State<RegisterWargaStep2> createState() => _RegisterWargaStep2State();
}

class _RegisterWargaStep2State extends State<RegisterWargaStep2> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _kodeRtController = TextEditingController();
  bool _isChecked = false;
  bool _isLoading = false;

  void _handleDaftar() async {
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Anda harus menyetujui syarat & ketentuan")));
      return;
    }
    
    setState(() => _isLoading = true);

    // Dummy email karena form tidak minta email
    final dummyEmail = "${_usernameController.text}@warga.app";

    final result = await ApiService.register(
      role: 'Warga',
      namaLengkap: widget.nama,
      nik: widget.nik,
      noKk: widget.noKk,
      tanggalLahir: widget.tglLahir,
      username: _usernameController.text,
      password: _passwordController.text,
      email: dummyEmail, 
      kodeInduk: _kodeRtController.text, // KODE UNIK RT
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      // Sukses, kembali ke Login
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pendaftaran Berhasil! Silakan Login.")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBE6),
      appBar: AppBar(
        title: const Text("Pendaftaran Akun Warga (2/2)"), 
        backgroundColor: Colors.transparent, 
        foregroundColor: Colors.black, 
        elevation: 0
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              
              // --- 2. LOGO BARU DI STEP 2 ---
              const Center(
                child: LogoWidget(height: 180, width: 180),
              ),
              const SizedBox(height: 30),
              // ------------------------------

              _buildInputBox("Buat Username", _usernameController),
              _buildInputBox("Buat Password", _passwordController, isPassword: true),
              
              // KODE RT WAJIB
              TextField(
                controller: _kodeRtController,
                decoration: InputDecoration(
                  labelText: "* Kode Unik RT (Wajib)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
                  filled: true, fillColor: Colors.white,
                  helperText: "Minta kode ini kepada Ketua RT Anda",
                  helperStyle: const TextStyle(color: Colors.red),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Checkbox(
                    value: _isChecked, 
                    activeColor: const Color(0xFF678267),
                    onChanged: (val) => setState(() => _isChecked = val!)
                  ),
                  const Expanded(child: Text("Saya Setuju dengan Syarat & Ketentuan", style: TextStyle(fontSize: 12))),
                ],
              ),

              const SizedBox(height: 30),

              _isLoading 
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleDaftar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF678267), // Hijau (Tema Logo)
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15)
                      ),
                      child: const Text("Daftar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBox(String hint, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true, fillColor: Colors.white,
        ),
      ),
    );
  }
}