// screens/auth/splash_screen.dart

import 'package:flutter/material.dart';
// Asumsi path ke login page adalah: lib/screens/auth/login_page.dart
import 'login_page.dart'; // Jika login_page.dart berada di folder yang sama

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
      // Menggunakan pushReplacement untuk transisi yang bersih
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()), // LoginPage() adalah tujuan
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // ... (Konten SplashScreen tetap sama)
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.home_work,
              color: Color(0xFF4CAF50), 
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'Manajemen RT/RW',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
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