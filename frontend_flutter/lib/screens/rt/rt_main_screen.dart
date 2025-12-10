import 'package:flutter/material.dart';

// Import screen
import 'dashboard_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';

// PENTING: Panggil file notifikasi yang BARU
import 'notification_screen.dart'; 

class RtMainScreen extends StatefulWidget {
  const RtMainScreen({super.key});

  @override
  State<RtMainScreen> createState() => _RtMainScreenState();
}

class _RtMainScreenState extends State<RtMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),      // Index 0
    const SearchScreen(),         // Index 1
    
    // PERBAIKAN DI SINI: Gunakan NotificationScreen
    const NotificationScreen(),   // Index 2 (Dulu VerifyListScreen)
    
    const ProfileScreen(),        // Index 3
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Warga'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}