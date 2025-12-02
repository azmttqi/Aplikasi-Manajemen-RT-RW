import 'package:flutter/material.dart';


class VerifyDetailScreen extends StatelessWidget {
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFFF8F2E5),
    appBar: AppBar(title: Text('Detail Warga')),
    body: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text('Nama Lengkap: Andianto Julian'),
            Text('NIK: 32145xxxxxxxxx'),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: Text('Setujui')),
            ElevatedButton(onPressed: () {}, child: Text('Tolak')),
          ],
        ), 
      ),
    );
  }
}