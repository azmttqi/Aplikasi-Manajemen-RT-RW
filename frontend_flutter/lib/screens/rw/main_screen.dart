import 'package:flutter/material.dart';
import '../../utils/global_keys.dart'; // 1. Import Kunci Ajaib

import 'super_admin_dashboard.dart'; 
import 'account_search_screen.dart'; 
import 'DetailAkunPage.dart'; 
import 'profil_screen.dart';
import 'notification_screen.dart';

class RwMainScreen extends StatefulWidget {
  // 2. Pasang Kunci (Tanpa const, Tanpa super.key)
  RwMainScreen() : super(key: mainScreenKey);

  @override
  // Hapus underscore (_) agar public
  State<RwMainScreen> createState() => RwMainScreenState();
}

// Hapus underscore (_) di sini juga
class RwMainScreenState extends State<RwMainScreen> {
  int _selectedIndex = 0;

  // 3. DAFTAR 4 HALAMAN (Sesuai keinginan Anda)
  final List<Widget> _widgetOptions = <Widget>[
    const SuperAdminDashboard(),      // Index 0: Home
    const AccountSearchScreen(),      // Index 1: Folder (Pencarian RT)
    const NotificationScreen(),  // Index 2 notifikasi
    const ProfileScreen(),     // Index 3: Profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 4. FUNGSI KHUSUS: Ganti Tab dari Luar (Dipanggil dari Dashboard)
  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gunakan IndexedStack agar halaman tersimpan (tidak reload saat pindah)
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green[800], // Warna latar hijau tua
        selectedItemColor: Colors.amber,    // Warna ikon aktif (kuning emas)
        unselectedItemColor: Colors.white,  // Warna ikon mati (putih)
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false, // Hilangkan label jika ingin gaya minimalis
        showUnselectedLabels: false,
        
        // 5. KEMBALIKAN 4 ICON
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder, size: 30),
            label: 'Warga',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: 30),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}