import 'dart:async'; // Import untuk Timer
import 'package:flutter/material.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Pindah ke LoginScreen setelah 3 detik
    Timer(
      const Duration(seconds: 3),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()), 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tidak perlu AppBar atau BottomNavigationBar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // GANTI INI DENGAN LOGO ANDA
            // Gunakan Image.asset('assets/images/logo_icon.png') jika punya file
            Icon(
              Icons.home_work_rounded, // Placeholder icon
              size: 100, // Ukuran lebih besar untuk splash
              color: Colors.green[800],
            ),
          ],
        ),
      ),
    );
  }
}