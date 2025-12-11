import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double height;
  final double width;

  const LogoWidget({
    super.key,
    this.height = 120.0, // Tinggi default, bisa diubah saat dipanggil
    this.width = 120.0,  // Lebar default
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_rt_rw.png', // Pastikan path ini sesuai dengan Langkah 1
      height: height,
      width: width,
      fit: BoxFit.contain, // Agar gambar tidak terpotong/gepeng
    );
  }
}