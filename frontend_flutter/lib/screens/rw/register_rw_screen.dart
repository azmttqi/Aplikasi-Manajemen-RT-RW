import 'package:flutter/material.dart';

class RegisterRwScreen extends StatefulWidget {
  const RegisterRwScreen({super.key});

  @override
  State<RegisterRwScreen> createState() => _RegisterRwScreenState();
}

class _RegisterRwScreenState extends State<RegisterRwScreen> {
  // Kunci untuk validasi form
  final _formKey = GlobalKey<FormState>();

  // Controller untuk setiap text field
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiPasswordController = TextEditingController();
  final _nomorRwController = TextEditingController();
  final _namaKetuaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _kodeUnikController = TextEditingController();

  // State untuk visibilitas password
  bool _isPasswordHidden = true;
  bool _isKonfirmasiPasswordHidden = true;

  @override
  void dispose() {
    // Selalu dispose controller setelah tidak digunakan
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    _nomorRwController.dispose();
    _namaKetuaController.dispose();
    _alamatController.dispose();
    _kodeUnikController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Footer yang sama
      bottomNavigationBar: Container(
        height: 50,
        color: const Color(0xFF678267), // Warna hijau footer
        child: const Center(
          child: Text(
            "©2025 Lingkar Warga App",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              // Rata kiri untuk judul
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // --- 1. Logo (di tengah) ---
                Center(child: _buildLogoSection()),
                const SizedBox(height: 32),

                // --- 2. Judul Utama ---
                const Text(
                  "Pendaftaran Super Admin RW & Kode Wilayah",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // --- 3. Kartu Form Pertama ---
                _buildFormCard(
                  title: "Data Akun Super Admin RW",
                  children: [
                    _buildFormRow(
                      label: "Nama Lengkap",
                      controller: _namaController,
                    ),
                    _buildFormRow(
                      label: "Email",
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildFormRow(
                      label: "Kata Sandi",
                      controller: _passwordController,
                      obscureText: _isPasswordHidden,
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordHidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined, size: 20,),
                        onPressed: () {
                          setState(() {
                            _isPasswordHidden = !_isPasswordHidden;
                          });
                        },
                      ),
                    ),
                    _buildFormRow(
                      label: "Konfirmasi Kata Sandi",
                      controller: _konfirmasiPasswordController,
                      obscureText: _isKonfirmasiPasswordHidden,
                      suffixIcon: IconButton(
                        icon: Icon(_isKonfirmasiPasswordHidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined, size: 20,),
                        onPressed: () {
                          setState(() {
                            _isKonfirmasiPasswordHidden =
                                !_isKonfirmasiPasswordHidden;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- 4. Kartu Form Kedua ---
                _buildFormCard(
                  title: "Data Wilayah RW",
                  children: [
                    _buildFormRow(
                      label: "Nomor RW",
                      controller: _nomorRwController,
                    ),
                    _buildFormRow(
                      label: "Nama Ketua RW",
                      controller: _namaKetuaController,
                    ),
                    _buildFormRow(
                      label: "Alamat/ Wilayah RW",
                      controller: _alamatController,
                    ),
                    _buildGeneratedCodeField( // Widget khusus untuk field Kode Unik
                      label: "Kode Unik",
                      controller: _kodeUnikController,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // --- 5. Tombol Daftar ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: () {
                      // if (_formKey.currentState!.validate()) {
                      //   // TODO: Proses logika pendaftaran di sini
                      // }
                    },
                    child: const Text(
                      "Daftar",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- 6. Link Login ---
                _buildLoginLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// WIDGET PEMBANTU UNTUK KARTU FORM
  Widget _buildFormCard(
      {required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white, // Latar belakang kartu putih
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[300]!), // Border abu-abu tipis
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24, thickness: 1), // Garis pemisah
          // Tampilkan semua children (field)
          ...children,
        ],
      ),
    );
  }

  /// WIDGET PEMBANTU UNTUK BARIS FORM (LABEL + TEXTFIELD)
  Widget _buildFormRow(
      {required String label,
      TextEditingController? controller,
      bool obscureText = false,
      TextInputType? keyboardType,
      Widget? suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          // Label
          SizedBox(
            width: 130, // Beri lebar tetap agar rapi
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
          // Text Field
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                // Meng-override tema default agar sesuai gambar
                isDense: true,
                contentPadding: const EdgeInsets.all(12),
                filled: true,
                fillColor: Colors.grey[200], // Warna abu-abu seperti di gambar
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none, // Tanpa border
                ),
                suffixIcon: suffixIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// WIDGET PEMBANTU KHUSUS UNTUK KODE UNIK
  Widget _buildGeneratedCodeField(
      {required String label, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
          // Text Field (read-only)
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: true, // Tidak bisa diisi manual
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.all(12),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Tombol "Generated Code"
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[100], // Biru muda
              foregroundColor: Colors.blue[800], // Teks biru tua
              padding: const EdgeInsets.symmetric(horizontal: 10),
              textStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              // TODO: Tambahkan logika generate kode unik di sini
              setState(() {
                controller?.text = "RW-A4B7C"; // Contoh hasil generate
              });
            },
            child: const Text("Generated Code"),
          )
        ],
      ),
    );
  }

  /// WIDGET PEMBANTU UNTUK LOGO (REUSED)
  Widget _buildLogoSection() {
    return Column(
      children: [
        Icon(
          Icons.home_work_rounded,
          size: 80,
          color: Colors.green[800],
        ),
        const SizedBox(height: 8),
        Text(
          "Manajemen RT/RW",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
        ),
        Text(
          "Membangun Komunitas Cerdas",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  /// WIDGET PEMBANTU UNTUK LINK LOGIN (REUSED)
  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Sudah Punya akun?",
          style: TextStyle(color: Colors.grey[700]),
        ),
        TextButton(
          onPressed: () {
            // Kembali ke halaman login
            // Kita gunakan popUntil agar kembali ke halaman paling awal (login)
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          child: const Text(
            "Login",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}