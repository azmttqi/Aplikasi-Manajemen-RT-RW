import 'package:flutter/material.dart';


class VerifyListScreen extends StatelessWidget {
  final List<Map<String, String>> warga = [
    {'nama': 'Andianto Julian', 'nik': '32145xxxxxxxx'},
    {'nama': 'Sulistiawati', 'nik': '32145xxxxxxxx'},
];


@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFFF8F2E5),
    appBar: AppBar(title: Text('Verifikasi Akun Warga Baru')),
    body: Column(
      children: warga.map((w) => cardItem(w, context)).toList(),
    ),
  );
}


Widget cardItem(w, context) {
    return Card(
      margin: EdgeInsets.all(12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(w['nama'], style: TextStyle(fontSize: 18)),
            Text('NIK: ${w['nik']}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(onPressed: () {}, child: Text('Setujui')),
                SizedBox(width: 10),
                ElevatedButton(onPressed: () {}, child: Text('Tolak')),
                SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/verifyDetail'),
                  child: Text('Detail'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}