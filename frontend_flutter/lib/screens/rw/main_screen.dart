import 'package:flutter/material.dart';
import '../../utils/global_keys.dart'; 
import 'super_admin_dashboard.dart'; 
import 'account_search_screen.dart'; 
import 'profil_screen.dart'; // Pastikan path benar
import 'notification_screen.dart'; // Pastikan path benar

class RwMainScreen extends StatefulWidget {
  // Pasang Kunci
  RwMainScreen() : super(key: mainScreenKey);

  @override
  State<RwMainScreen> createState() => RwMainScreenState();
}

class RwMainScreenState extends State<RwMainScreen> {
  int _selectedIndex = 0;

  // DAFTAR 4 HALAMAN
  final List<Widget> _widgetOptions = <Widget>[
    const SuperAdminDashboard(),      // Index 0: Home
    const AccountSearchScreen(),      // Index 1: Warga
    const NotificationScreen(),       // Index 2: Notifikasi
    const ProfileScreen(),            // Index 3: Profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga state halaman agar tidak reload saat pindah tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3), // Efek bayangan ke atas
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,      // GANTI JADI PUTIH (Lebih Clean)
          selectedItemColor: Colors.green[700], // Icon Aktif: HIJAU TUA
          unselectedItemColor: Colors.grey,     // Icon Mati: ABU-ABU
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showSelectedLabels: true,  // Tampilkan label agar user tidak bingung
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder),
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
      ),
    );
  }
}