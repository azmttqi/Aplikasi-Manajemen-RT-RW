import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_card.dart';

class DashboardRW extends StatefulWidget {
  const DashboardRW({super.key});

  @override
  State<DashboardRW> createState() => _DashboardRWState();
}

class _DashboardRWState extends State<DashboardRW> {
  bool isLoading = true;
  Map<String, dynamic>? dashboardData;
  String? errorMessage;

  @override  
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    final result = await ApiService.getDashboardRW();

    if (result['success']) {
      setState(() {
        dashboardData = result['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = result['message'];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard RW"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Wilayah: ${dashboardData!['nama_rw']}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            CustomCard(
                              title: "Jumlah RT",
                              value: dashboardData!['jumlah_rt'],
                              color: Colors.blueAccent,
                            ),
                            CustomCard(
                              title: "Total Warga",
                              value: dashboardData!['total_warga'],
                              color: Colors.teal,
                            ),
                            CustomCard(
                              title: "Disetujui",
                              value: dashboardData!['disetujui'],
                              color: Colors.green,
                            ),
                            CustomCard(
                              title: "Pending",
                              value: dashboardData!['pending'],
                              color: Colors.orange,
                            ),
                            CustomCard(
                              title: "Ditolak",
                              value: dashboardData!['ditolak'],
                              color: Colors.redAccent,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
