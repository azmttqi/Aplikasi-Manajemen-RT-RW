// screens/auth/main_screen.dart

import 'package:flutter/material.dart';
import '../rw/account_search_screen.dart'; 
import '../rw/super_admin_dashboard.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; 

  // Daftar halaman yang TIDAK memiliki Scaffold
  final List<Widget> _widgetOptions = <Widget>[
    const SuperAdminDashboard(), // Index 0: Dashboard
    const AccountSearchScreen(),  // Index 1: Pencarian Akun
    const Center(child: Text('Halaman Notifikasi', style: TextStyle(fontSize: 24, color: Colors.black))),
    const Center(child: Text('Halaman Profil', style: TextStyle(fontSize: 24, color: Colors.black))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🚀 PERBAIKAN BNAV: Gunakan IndexedStack
      // Ini menjamin BNAV tidak terblokir dan mempertahankan state halaman.
      body: IndexedStack(
        index: _selectedIndex, 
        children: _widgetOptions,
      ), 
      
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, 
        backgroundColor: Colors.green[800], 
        selectedItemColor: Colors.amber, 
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex, 
        onTap: _onItemTapped, 
        
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.folder, size: 30), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications, size: 30), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 30), label: ''),
        ],
      ),
    );
  }
}