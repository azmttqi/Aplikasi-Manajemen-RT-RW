import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ⚠️ PENTING:
  // Ganti 'localhost' dengan '10.0.2.2' jika menggunakan Emulator Android.
  // Ganti dengan IP Laptop (misal 192.168.1.x) jika menggunakan HP Fisik.
  static const String baseUrl = "http://localhost:5000/api";

  static String? _token; 

  // === TOKEN MANAGEMENT ===
  static void setToken(String token) {
    _token = token;
  }

  static Future<String?> getToken() async {
    return _token;
  }

  static Future<void> logout() async {
    _token = null;
  }

  // ===========================================================================
  // 1. AUTHENTICATION (Login, Register, Get Me, Update Profile)
  // ===========================================================================

  static Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "identifier": identifier,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setToken(data['token']);
        
        final user = data['user'];
        int roleId = 0;
        if (user['id_role'] != null) {
          roleId = int.parse(user['id_role'].toString());
        } else if (user['role'] != null) {
          roleId = int.parse(user['role'].toString());
        }

        String roleName;
        switch (roleId) {
          case 1: roleName = "RW"; break; 
          case 2: roleName = "RT"; break;
          case 3: roleName = "Warga"; break;
          default: roleName = "unknown";
        }

        return {
          "success": true,
          "token": data['token'],
          "role": roleName,
          "user": user,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "message": data['message'] ?? "Login gagal",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String role, 
    required String namaLengkap,
    required String email,
    required String username,
    required String password,
    String? nik,
    String? noKk,
    String? tanggalLahir,
    String? nomorWilayah, 
    String? alamatWilayah, 
    String? kodeWilayahBaru,
    String? kodeInduk,
  }) async {
    try {
      String endpoint = "";
      if (role == 'RW') endpoint = "/auth/register-rw";
      else if (role == 'RT') endpoint = "/auth/register-rt";
      else if (role == 'Warga') endpoint = "/auth/register-warga";
      
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
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return { "success": true, "message": data['message'] };
      } else {
        return { "success": false, "message": data['message'] ?? "Registrasi gagal" };
      }
    } catch (e) {
      return {"success": false, "message": "Koneksi Error: $e"};
    }
  }

  static Future<Map<String, dynamic>?> getMe() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/auth/me"), 
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']; 
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // [BARU] Fungsi untuk Melengkapi Data Warga
  static Future<Map<String, dynamic>> updateDataWarga(Map<String, dynamic> data) async {
    final token = await getToken(); // Pastikan kamu punya fungsi getToken
    if (token == null) return {'success': false, 'message': 'Token tidak ditemukan'};

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/warga/update-data'), // Sesuaikan endpoint di routes backend
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': responseData['message']};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'Gagal menyimpan data'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String currentPassword,
    String? newEmail,
    String? newUsername,
    String? newPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/auth/update"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: jsonEncode({
          "currentPassword": currentPassword,
          "email": newEmail,
          "username": newUsername,
          "newPassword": newPassword,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal update'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  // ===========================================================================
  // 2. DATA WARGA & SEARCH (Digunakan RT & Search Screen)
  // ===========================================================================

  static Future<List<dynamic>> getWargaList({String query = ""}) async {
    try {
      // Sesuai route backend: router.get("/", ...) di file warga
      final url = Uri.parse("$baseUrl/warga?search=$query");
      
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? []; 
      }
      return [];
    } catch (e) {
      return []; 
    }
  }

  // Edit Data Warga Lengkap (RT Action)
  static Future<bool> editWarga(int idWarga, Map<String, dynamic> data) async {
    try {
      // Pastikan endpointnya pakai ID (/warga/:id)
      final response = await http.put(
        Uri.parse("$baseUrl/warga/$idWarga"), 
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: jsonEncode(data),
      );
      
      print("✏️ Edit Warga ID $idWarga: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error editWarga: $e");
      return false;
    }
  }

  static Future<bool> deleteWarga(int idWarga) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/warga/$idWarga"),
        headers: {"Authorization": "Bearer $_token"},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ===============================================================
  // 🟢 FIX: AMBIL 2 DATA SEKALIGUS (WARGA BARU + PENGAJUAN)
  // ===============================================================
static Future<Map<String, dynamic>?> getRtNotifications() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('$baseUrl/warga/pending'), headers: {'Authorization': 'Bearer $_token'}),      // 0: Baru
        http.get(Uri.parse('$baseUrl/warga/pengajuan/rt'), headers: {'Authorization': 'Bearer $_token'}), // 1: Update Data
        http.get(Uri.parse('$baseUrl/warga/rejected'), headers: {'Authorization': 'Bearer $_token'}),     // 2: Ditolak (BARU)
      ]);

      // Helper function biar kodingan pendek
      List<dynamic> parse(http.Response res) {
        if (res.statusCode == 200) return jsonDecode(res.body)['data'] ?? [];
        return [];
      }

      return {
        "pendaftaran_baru": parse(responses[0]),
        "pengajuan_update": parse(responses[1]),
        "warga_ditolak": parse(responses[2]), // <--- Data Baru
      };

    } catch (e) {
      print("❌ Error Notif: $e");
      return null;
    }
  }

  // 2. Verifikasi Warga (Tombol Setujui/Tolak)
  // Sesuai Backend: router.put("/verify/:id_warga", ...) -> /api/warga/verify/:id
  static Future<bool> verifyWargaBaru(int id, String status) async {
    try {
      final url = Uri.parse("$baseUrl/warga/verify/$id");
      
      print("🚀 Kirim Verifikasi ke: $url");
      print("📦 Data: { status: $status }");

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': status, // Backend biasanya terima 'disetujui' atau 'ditolak'
        }),
      );

      print("📩 Response Verifikasi: ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error verifyWargaBaru: $e");
      return false;
    }
  }

  // 3. Placeholder Update Data (Biar file notifikasi tidak merah)
// Update Status Pengajuan Perubahan Data (Setujui/Tolak)
  static Future<bool> verifyUpdateData(int idPengajuan, String status) async {
    try {
      // Endpoint ini akan kita buat di backend sebentar lagi
      final url = Uri.parse("$baseUrl/warga/pengajuan/verify/$idPengajuan");
      
      print("🚀 Memproses Pengajuan ID: $idPengajuan -> Status: $status");

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': status, // 'disetujui' atau 'ditolak'
        }),
      );

      print("📩 Response Server: ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error verifyUpdateData: $e");
      return false;
    }
  }
  // ===========================================================================
  // 4. FITUR KHUSUS RW & DASHBOARD
  // ===========================================================================

  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/dashboard/stats"), 
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Gagal load data"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getSuperAdminDashboard() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/warga/rw/dashboard"),
        headers: {"Authorization": "Bearer $_token"},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data['data']};
      } else {
        return {"success": false, "message": "Gagal mengambil data"};
      }
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }

  static Future<List<dynamic>> getRwNotifications() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/warga/rw/notifications"), 
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']; 
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
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ===========================================================================
  // 5. FITUR WARGA (PENGAJUAN)
  // ===========================================================================

  static Future<bool> ajukanPerubahan(String keterangan) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/warga/pengajuan"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: jsonEncode({"keterangan": keterangan}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<dynamic>> getRiwayatPengajuan() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/warga/pengajuan/riwayat"),
        headers: {"Authorization": "Bearer $_token"},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

// ===========================================================================
  // 6. get statistik per RT  
  // ===========================================================================

static Future<List<dynamic>> getStatistikPerRt() async {
    // SEKARANG ERROR INI AKAN HILANG
    final prefs = await SharedPreferences.getInstance(); 
    final token = prefs.getString('token');

    final url = Uri.parse('$baseUrl/dashboard/stats/per-rt');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final result = jsonDecode(response.body);
    if (response.statusCode == 200 && result['success'] == true) {
      return result['data'];
    } else {
      throw Exception(result['message'] ?? 'Gagal mengambil data per RT');
    }
  }
}