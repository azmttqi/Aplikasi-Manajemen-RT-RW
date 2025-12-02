import 'package:flutter/material.dart';


class ProfileScreen extends StatelessWidget {
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFFF8F2E5),
    appBar: AppBar(title: Text('Profil RT')),
    body: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(radius: 40),
          SizedBox(height: 10),
          Text('Nasution', style: TextStyle(fontSize: 20)),
          Text('RT 001'),
          Divider(),
          list('Ubah Kata Sandi'),
          list('Ubah Email & No HP'),
          list('Alamat / Wilayah'),
          list('Dukungan & Bantuan'),
          SizedBox(height: 20),
          ElevatedButton(onPressed: () {}, child: Text('Log Out')),
        ],
      ),
    ),
  );
}


Widget list(String text) {
    return ListTile(
      title: Text(text),
      trailing: Icon(Icons.arrow_forward_ios),
    );
  }
}