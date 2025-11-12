import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:5000/api";

  static String? _token; // Token JWT disimpan di sini sementara

  // Simpan token setelah login
  static void setToken(String token) {
    _token = token;
  }

  static String? get token => _token;

  // === LOGIN ===
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setToken(data['token']); // simpan token

        return {
          "success": true,
          "token": data['token'],
          "role": data['role'] ?? "unknown",
        };
      } else {
        final data = jsonDecode(response.body);
        return {"success": false, "message": data['message'] ?? "Login gagal"};
      }
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }

  // === DASHBOARD RW ===
  static Future<Map<String, dynamic>> getDashboardRW() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/warga/rw/dashboard"),
        headers: {
          "Authorization": "Bearer $_token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data['data']};
      } else {
        final data = jsonDecode(response.body);
        return {"success": false, "message": data['message'] ?? "Gagal mengambil data"};
      }
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }
}
