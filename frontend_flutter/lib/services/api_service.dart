import 'dart:convert';
import 'dart:async'; // Tambahan untuk Timeout
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // ===========================================================================
  // ⚙️ KONFIGURASI PUSAT (Ganti IP di sini saja)
  // ===========================================================================
  // - Pakai '10.0.2.2' jika pakai Emulator Android
  // - Pakai IP Laptop (misal '192.168.1.5') jika pakai HP Asli (Harus satu WiFi)
  static const String baseUrl = "https://rtrw.demo.tazkia.ac.id/api";

  static const Duration _timeout = Duration(seconds: 15); // Batas waktu koneksi

  // ===========================================================================
  // 🔐 TOKEN & HEADER MANAGEMENT
  // ===========================================================================
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Helper: Membuat Header otomatis (supaya tidak ngetik ulang terus)
  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // ===========================================================================
  // 1. OTENTIKASI (Login, Register, Lupa Password)
  // ===========================================================================

  static Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"identifier": identifier, "password": password}),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await setToken(data['token']);
        
        // Logika penentuan Role
        final user = data['user'];
        int roleId = user['id_role'] ?? user['role'] ?? 0;
        
        String roleName = "unknown";
        if (roleId == 1) roleName = "RW";
        else if (roleId == 2) roleName = "RT";
        else if (roleId == 3) roleName = "Warga";

        return {
          "success": true,
          "token": data['token'],
          "role": roleName,
          "user": user,
        };
      } else {
        return {"success": false, "message": data['message'] ?? "Login gagal"};
      }
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String role, 
    required String namaLengkap,
    required String email,
    required String username,
    required String password,
    String? nik, String? noKk, String? tanggalLahir,
    String? nomorWilayah, String? alamatWilayah, 
    String? kodeWilayahBaru, String? kodeInduk,
  }) async {
    try {
      String endpoint = "/auth/register-warga"; // Default
      if (role == 'RW') endpoint = "/auth/register-rw";
      else if (role == 'RT') endpoint = "/auth/register-rt";
      
      final response = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nama_lengkap": namaLengkap,
          "email": email,
          "username": username,
          "password": password,
          "nik": nik,
          "no_kk": noKk,
          "tanggal_lahir": tanggalLahir,
          "nomor_rw": role == 'RW' ? nomorWilayah : null,
          "nomor_rt": role == 'RT' ? nomorWilayah : null,
          "alamat": alamatWilayah,
          "kode_wilayah_baru": kodeWilayahBaru,
          "kode_rw_induk": role == 'RT' ? kodeInduk : null,
          "kode_rt_induk": role == 'Warga' ? kodeInduk : null,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      return {
        "success": response.statusCode == 201,
        "message": data['message'] ?? "Registrasi gagal"
      };
    } catch (e) {
      return {"success": false, "message": "Koneksi Error: $e"};
    }
  }

  static Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      ).timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      print("Error forgotPassword: $e");
      return false;
    }
  }

  // ===========================================================================
  // 2. PROFILE & USER DATA (Get Me, Update Data)
  // ===========================================================================

  static Future<Map<String, dynamic>?> getMe() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/auth/me"), 
        headers: await _getHeaders(),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data']; 
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update Data Lengkap (Dipakai di lengkapi_profil_screen.dart)
  static Future<Map<String, dynamic>> updateDataWarga(Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/warga/update-data'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      ).timeout(_timeout);

      final result = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': result['message'] ?? 'Gagal menyimpan data'
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // Update Username/Password/Email
  static Future<Map<String, dynamic>> updateProfile({
    required String currentPassword,
    String? newEmail, String? newUsername, String? newPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/auth/update"),
        headers: await _getHeaders(),
        body: jsonEncode({
          "currentPassword": currentPassword,
          "email": newEmail,
          "username": newUsername,
          "newPassword": newPassword,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Gagal update'
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  // ===========================================================================
  // 3. FITUR RT (Manajemen Warga)
  // ===========================================================================

static Future<List<dynamic>> getWargaList({String query = "", String ageGroup = ""}) async {
    try {
      // Menambahkan age_group ke URL parameter
      final url = Uri.parse("$baseUrl/warga?search=$query&age_group=$ageGroup");
      
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'] ?? []; 
      }
      return [];
    } catch (e) {
      print("Error getWargaList: $e");
      return []; 
    }
  }

  static Future<bool> editWarga(int idWarga, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/warga/$idWarga"), 
        headers: await _getHeaders(),
        body: jsonEncode(data),
      ).timeout(_timeout);
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteWarga(int idWarga) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/warga/$idWarga"),
        headers: await _getHeaders(),
      ).timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Mengambil Notifikasi Dashboard RT (Pending, Pengajuan, Ditolak)
  static Future<Map<String, dynamic>?> getRtNotifications() async {
    try {
      final headers = await _getHeaders();
      
      final responses = await Future.wait([
        http.get(Uri.parse('$baseUrl/warga/pending'), headers: headers),      // 0: Warga Baru
        http.get(Uri.parse('$baseUrl/warga/pengajuan/rt'), headers: headers), // 1: Update Data
        http.get(Uri.parse('$baseUrl/warga/rejected'), headers: headers),     // 2: Ditolak
      ]);

      List<dynamic> parse(http.Response res) {
        if (res.statusCode == 200) return jsonDecode(res.body)['data'] ?? [];
        return [];
      }

      return {
        "pendaftaran_baru": parse(responses[0]),
        "pengajuan_update": parse(responses[1]),
        "warga_ditolak": parse(responses[2]),
      };
    } catch (e) {
      print("❌ Error Notif: $e");
      return null;
    }
  }

  // Verifikasi Warga Baru
  static Future<bool> verifyWargaBaru(int id, String status) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/warga/verify/$id"),
        headers: await _getHeaders(),
        body: jsonEncode({'status': status}),
      ).timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Verifikasi Pengajuan Perubahan Data
  static Future<bool> verifyUpdateData(int idPengajuan, String status) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/warga/pengajuan/verify/$idPengajuan"),
        headers: await _getHeaders(),
        body: jsonEncode({'status': status}),
      ).timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

// [BARU] Mengambil Statistik Detail RT (Gender & Usia Otomatis)
  static Future<Map<String, dynamic>?> getStatistikWargaRT() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/warga/statistik/rt"),
        headers: await _getHeaders(),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']; // Mengambil object data (total_pria, total_lansia, dll)
      }
      return null;
    } catch (e) {
      print("Error getStatistikWargaRT: $e");
      return null;
    }
  }

  // ===========================================================================
  // 4. FITUR RW (Dashboard & Statistik)
  // ===========================================================================

  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/dashboard/stats"), 
        headers: await _getHeaders(),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Gagal load data"};
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<List<dynamic>> getRwNotifications() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/warga/rw/notifications"), 
        headers: await _getHeaders(),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data']; 
      }
    } catch (e) {
      print("Error getRwNotifications: $e");
    }
    return [];
  }

  static Future<bool> verifyAccount(int idUser) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/warga/rw/verify/$idUser"),
        headers: await _getHeaders(),
      ).timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<dynamic>> getStatistikPerRt() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/stats/per-rt'),
        headers: await _getHeaders(),
      ).timeout(_timeout);

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['success'] == true) {
        return result['data'];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ===========================================================================
  // 5. FITUR WARGA (Pengajuan & Notifikasi)
  // ===========================================================================

  static Future<bool> ajukanPerubahan(String keterangan) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/warga/pengajuan"),
        headers: await _getHeaders(),
        body: jsonEncode({"keterangan": keterangan}),
      ).timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<dynamic>> getRiwayatPengajuan() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/warga/pengajuan/riwayat"),
        headers: await _getHeaders(),
      ).timeout(_timeout);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getNotifikasiWarga() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/warga/notifikasi'),
        headers: await _getHeaders(),
      ).timeout(_timeout);

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['success'] == true) {
        return result['data'];
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  // [BARU] Mengambil Statistik Detail RW (Lintas RT)
  static Future<Map<String, dynamic>?> getStatistikWargaRWDetail() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/warga/rw/statistik/detail"),
        headers: await _getHeaders(),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print("Error getStatistikWargaRW: $e");
      return null;
    }
  }
    static Future<Map<String, dynamic>?> getStatistikRWLengkap() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/warga/rw/statistik/rincian"),
        headers: await _getHeaders(),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Mengembalikan {summary: ..., rt_list: ...}
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}