import 'package:flutter/material.dart';

// Import halaman-halaman Warga
import 'warga_dashboard.dart';
import 'warga_profile_screen.dart';
import 'notification_screen.dart';

class WargaMainScreen extends StatefulWidget {
  const WargaMainScreen({super.key});

  @override
  State<WargaMainScreen> createState() => _WargaMainScreenState();
}

class _WargaMainScreenState extends State<WargaMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const WargaDashboard(),       // Index 0: Beranda
    const WargaNotificationScreen(),   // Index 1: Notifikasi (Pakai file RW)
    const WargaProfileScreen(),   // Index 2: Profil Warga
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
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