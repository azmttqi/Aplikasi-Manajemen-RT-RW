import 'package:flutter/material.dart';
import 'register_rt_screen.dart';
import '../rt/dashboard_screen.dart';
import '../rt/search_screen.dart';
import '../rt/profile_screen.dart';
import '../rt/verify_list_screen.dart';
import '../rt/verify_detail_screen.dart';


void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => DashboardScreen(),
        '/register': (context) => RegisterScreen(),
        '/search': (context) => SearchScreen(),
        '/profile': (context) => ProfileScreen(),
        '/verify': (context) => VerifyListScreen(),
        '/verifyDetail': (context) => VerifyDetailScreen(),
      },
    ); 
  }
}