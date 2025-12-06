import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class FormPengajuanScreen extends StatefulWidget {
  const FormPengajuanScreen({super.key});

  @override
  State<FormPengajuanScreen> createState() => _FormPengajuanScreenState();
}

class _FormPengajuanScreenState extends State<FormPengajuanScreen> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  void _kirimPengajuan() async {
    if (_controller.text.isEmpty) return;

    setState(() => _isLoading = true);
    bool success = await ApiService.ajukanPerubahan(_controller.text);
    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pengajuan terkirim! ✅")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mengirim pengajuan")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajukan Perubahan Data"), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Apa yang ingin Anda ubah?", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Contoh: Nama saya salah ketik, seharusnya 'Budi Santoso'. Mohon diperbaiki.",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _kirimPengajuan,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Kirim Pengajuan"),
              ),
            )
          ],
        ),
      ),
    );
  }
}