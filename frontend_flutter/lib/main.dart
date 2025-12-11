// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/auth/splash_screen.dart'; 
import 'screens/auth/login_page.dart'; // <--- 1. JANGAN LUPA IMPORT INI

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manajemen RT/RW',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFFAF9F6), 
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.blue, width: 2.0),
          ),
        ),
      ),
      
      // Halaman pertama yang dibuka
      home: const SplashScreen(),
      
      // Hilangkan banner debug
      debugShowCheckedModeBanner: false,

      // === 2. TAMBAHKAN BAGIAN INI (DAFTAR RUTE) ===
      routes: {
        // Nama rute : (context) => NamaClassHalamannya()
        '/login': (context) => const LoginPage(), 
        // Nanti kalau ada halaman lain, daftarkan di sini juga.
        // Contoh: '/dashboard': (context) => const DashboardScreen(),
      },
      // ============================================
    );
  }
}