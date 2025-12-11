import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tambahan untuk format input angka
import '../../../services/api_service.dart';
import '../../widgets/logo_widget.dart';

// === HALAMAN 1: DATA DIRI (DENGAN VALIDASI 16 DIGIT) ===
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
    // --- 1. VALIDASI NIK & KK WAJIB 16 DIGIT ---
    String nik = _nikController.text.trim();
    String kk = _kkController.text.trim();
    String nama = _namaController.text.trim();
    String tgl = _tglLahirController.text.trim();

    if (nik.isEmpty || kk.isEmpty || nama.isEmpty || tgl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua data wajib diisi!"), backgroundColor: Colors.red),
      );
      return;
    }

    if (nik.length != 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("NIK harus terdiri dari 16 digit angka!"), backgroundColor: Colors.red),
      );
      return;
    }

    if (kk.length != 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No. KK harus terdiri dari 16 digit angka!"), backgroundColor: Colors.red),
      );
      return;
    }
    // -------------------------------------------

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterWargaStep2(
          nik: nik,
          noKk: kk,
          nama: nama,
          tglLahir: tgl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBE6),
      appBar: AppBar(
        title: const Text("Pendaftaran Akun Warga (1/2)"), 
        backgroundColor: Colors.transparent, 
        foregroundColor: Colors.black, 
        elevation: 0
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Center(
                child: LogoWidget(height: 180, width: 180),
              ),
              const SizedBox(height: 30),

              // Form dengan Validasi Panjang Karakter
              _buildInputBox("Nomor Induk Kependudukan (NIK)", _nikController, isNumber: true, maxLength: 16),
              _buildInputBox("Nomor Kartu Keluarga", _kkController, isNumber: true, maxLength: 16),
              _buildInputBox("Nama Lengkap (Sesuai KTP)", _namaController),
              
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
                    backgroundColor: const Color(0xFF678267),
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

  Widget _buildInputBox(String hint, TextEditingController controller, {bool isNumber = false, int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLength: maxLength, // Membatasi input UI
        // Hanya izinkan angka jika isNumber = true
        inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
        decoration: InputDecoration(
          labelText: hint,
          counterText: "", // Menyembunyikan hitungan 0/16 di bawah textfield agar rapi
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true, fillColor: Colors.white,
        ),
      ),
    );
  }
}

// === HALAMAN 2: AKUN & KODE (LOGIC POPUP SUKSES) ===
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

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty || _kodeRtController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Username, Password, dan Kode RT wajib diisi!")));
      return;
    }
    
    setState(() => _isLoading = true);

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
      kodeInduk: _kodeRtController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      // 1. Tampilkan pesan sukses sebentar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pendaftaran Berhasil! Silakan Login."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        )
      );

      // 2. Langsung lempar ke Halaman Login & Hapus Riwayat Back Button
      // (Jeda sedikit 1 detik biar user sempat baca pesan sukses)
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      });
      // ----------------------------------------------------
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
              const Center(
                child: LogoWidget(height: 180, width: 180),
              ),
              const SizedBox(height: 30),

              _buildInputBox("Buat Username", _usernameController),
              _buildInputBox("Buat Password", _passwordController, isPassword: true),
              
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
                        backgroundColor: const Color(0xFF678267),
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