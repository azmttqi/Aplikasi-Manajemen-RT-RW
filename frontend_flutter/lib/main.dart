import 'package:flutter/material.dart';
import './screens/auth/splash_screen.dart'; 

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
        // Atur warna background default aplikasi
        scaffoldBackgroundColor: const Color(0xFFFAF9F6), // Warna krem muda
        // Atur tema untuk input field
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
      // Mulai aplikasi dari SplashScreen
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}