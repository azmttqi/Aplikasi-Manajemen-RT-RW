import 'package:flutter/material.dart';

class DashboardRT extends StatelessWidget {
  const DashboardRT({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard RT")),
      body: const Center(
        child: Text("Halo RT! Ini halaman Dashboard RT."),
      ),
    );
  }
}
