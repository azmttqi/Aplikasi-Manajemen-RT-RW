// screens/auth/splash_screen.dart

import 'package:flutter/material.dart';
// Asumsi path ke login page adalah: lib/screens/auth/login_page.dart
import 'login_page.dart'; 
import '../../widgets/logo_widget.dart'; // Pastikan path ini benar

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // 🚀 LOGIKA NAVIGASI: Pindah ke LoginPage setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) { // Cek mounted agar aman jika widget sudah didispose
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()), 
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            // --- BAGIAN INI YANG DIGANTI ---
            // Menggunakan LogoWidget agar gambar logo baru muncul
            const LogoWidget(
              height: 220, // Ukuran logo di Splash Screen
              width: 220,
            ),
            // -------------------------------

            //const SizedBox(height: 20),
            
            //Text(
              //'Manajemen RT/RW',
              //style: TextStyle(
              //fontSize: 24,
              //fontWeight: FontWeight.bold,
              //color: Colors.green[800],
              //),
           //),
            
            const SizedBox(height: 50),
            
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}