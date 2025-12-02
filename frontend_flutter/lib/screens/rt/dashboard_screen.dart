import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F2E5),
      appBar: AppBar(
        title: Text('Dashboard Admin RT 001'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            cardInfo('Jumlah Warga', '25.000'),
            cardInfo('Jumlah KK', '1.500'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: navIndex,
        onTap: (i) {
          setState(() => navIndex = i);
          if (i == 2) Navigator.pushNamed(context, '/search');
          if (i == 3) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }

  Widget cardInfo(String title, String value) {
    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
