import 'package:flutter/material.dart';


class SearchScreen extends StatelessWidget {
  final List<Map<String, String>> warga = [
    {'nik': '32145xxxxxxxxx', 'nama': 'Andianto Julian'},
    {'nik': '32145xxxxxxxxx', 'nama': 'Sulistiawati'},
];


@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFFF8F2E5),
    appBar: AppBar(title: Text('Pencarian Data Warga')),
    body: ListView(
      children: warga.map((w) => listItem(w, context)).toList(),
    ),
  );
}


Widget listItem(w, context) {
    return ListTile(
      title: Text(w['nama']),
      subtitle: Text(w['nik']),
      trailing: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/verifyDetail'),
        child: Text('Detail'),
      ),
    );
  }
}