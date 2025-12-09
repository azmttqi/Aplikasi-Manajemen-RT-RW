import 'package:flutter/material.dart';

// --- IMPORT SESUAI STRUKTUR FOLDER ANDA ---
import 'dashboard_screen.dart'; 
import 'search_screen.dart'; 
import 'profile_screen.dart'; 
// import 'verify_list_screen.dart'; // <-- INI YANG LAMA (HAPUS ATAU KOMENTAR)
import 'notification_screen.dart';   // <-- INI FILE BARU (Pastikan namanya benar)

class RtMainScreen extends StatefulWidget {
  const RtMainScreen({super.key});

  @override
  State<RtMainScreen> createState() => _RtMainScreenState();
}

class _RtMainScreenState extends State<RtMainScreen> {
  int _selectedIndex = 0; 

  // Daftar Halaman
  final List<Widget> _pages = [
    const DashboardScreen(),     // Index 0: Dashboard RT
    SearchScreen(),              // Index 1: Data Warga (Search)
    
    // --- PERBAIKAN DI SINI ---
    const NotificationScreen(),  // Index 2: Panggil class NotificationScreen yang baru
    
    ProfileScreen(),             // Index 3: Profil RT
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people), 
            label: 'Warga',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}