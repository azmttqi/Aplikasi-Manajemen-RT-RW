import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:5000/api/auth";

  static String? _token; // Token JWT disimpan di sini sementara

// === FUNGSI REGISTER UPDATE ===
  static Future<Map<String, dynamic>> register({
    required String role, 
    required String namaLengkap,
    required String email,
    required String username,
    required String password,
    
    // Parameter Tambahan (Opsional, tergantung Role)
    String? nik,
    String? noKk,
    String? tanggalLahir, // Format YYYY-MM-DD
    String? nomorWilayah, // Nomor RW atau RT (misal "05")
    String? alamatWilayah, 
    String? kodeWilayahBaru, // Kode yang DI-GENERATE (untuk RW/RT baru)
    String? kodeInduk, // Kode Verifikasi (RW Induk atau RT Induk)
  }) async {
    try {
      String endpoint = "";
      if (role == 'RW') endpoint = "/register-rw";
      else if (role == 'RT') endpoint = "/register-rt";
      else if (role == 'Warga') endpoint = "/register-warga";
      
      final url = Uri.parse("$baseUrl$endpoint");

      // Mapping data ke JSON Backend
      final Map<String, dynamic> bodyData = {
        "nama_lengkap": namaLengkap,
        "email": email,
        "username": username,
        "password": password,
        
        // Field tambahan (akan null jika tidak diisi)
        "nik": nik,
        "no_kk": noKk,
        "tanggal_lahir": tanggalLahir,
        
        // Wilayah
        "nomor_rw": role == 'RW' ? nomorWilayah : null,
        "nomor_rt": role == 'RT' ? nomorWilayah : null,
        "alamat": alamatWilayah,
        "kode_wilayah_baru": kodeWilayahBaru, // Kode Hasil Generate

        // Validasi Induk
        "kode_rw_induk": role == 'RT' ? kodeInduk : null,
        "kode_rt_induk": role == 'Warga' ? kodeInduk : null,
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyData),
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
  
  // Simpan token setelah login
  static void setToken(String token) {
    _token = token;
  }

  static String? get token => _token;

// === LOGIN (VERSI PERBAIKAN) ===
  static Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"), // Pastikan ini benar
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "identifier": identifier,
          "password": password,
        }),
      );

      print("🔹 Response Status: ${response.statusCode}"); // Debugging
      print("🔹 Response Body: ${response.body}"); // Debugging (Cek isinya di terminal)

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setToken(data['token']);
        
        final user = data['user'];
        
        // --- PERBAIKAN DI SINI ---
        // Kita coba ambil 'id_role' ATAU 'role'. Jika null, default ke 0.
        // Kita juga pastikan dia dikonversi jadi int.
        int roleId = 0;
        if (user['id_role'] != null) {
          roleId = int.parse(user['id_role'].toString());
        } else if (user['role'] != null) {
          roleId = int.parse(user['role'].toString());
        }

        print("🔹 Role ID yang terbaca: $roleId"); 

        String roleName;
        // Pastikan ID ini sesuai dengan database kamu
        // 1 = RW, 2 = RT, 3 = Warga (Sesuaikan dengan isi tabel roles)
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
      print("🔥 Error Login: $e");
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }

  // === AMBIL DATA PROFIL (GET ME) ===
  static Future<Map<String, dynamic>?> getMe() async {
    try {
      final response = await http.get(
        // Sesuaikan IP: Ganti localhost dengan 10.0.2.2 jika pakai Emulator Android
        Uri.parse("http://localhost:5000/api/auth/me"), 
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token", // Kirim token yang disimpan saat login
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']; // Kembalikan objek data user
      } else {
        return null;
      }
    } catch (e) {
      print("Error getMe: $e");
      return null;
    }
  }

  // === AMBIL DATA DASHBOARD ===
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/dashboard/stats"), 
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token", // <--- PENTING: Kirim Token
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Jika token expired (401/403), bisa handle logout di sini
        return {"success": false, "message": "Gagal load data: ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // === DASHBOARD RW ===
  static Future<Map<String, dynamic>> getSuperAdminDashboard() async {
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
        return {
          "success": false,
          "message": data['message'] ?? "Gagal mengambil data"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }

// === FUNGSI BARU: AMBIL LIST WARGA / RT ===
  // Tambahkan kode ini di dalam class ApiService
  
  static Future<List<dynamic>> getWargaList({String query = ""}) async {
    try {
      // Pastikan URL ini benar. 
      // Kalau baseUrl kamu ".../api/auth", kita harus mundur ke ".../api/warga"
      // Cara paling aman tulis manual saja:
      final url = Uri.parse("http://localhost:5000/api/warga?search=$query");
      // (Ganti localhost jadi 10.0.2.2 jika pakai Emulator Android)

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token", // PENTING: Token login harus dikirim
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend mengirim format: { success: true, role: 'RW', data: [...] }
        return data['data']; 
      } else {
        throw Exception("Gagal mengambil data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error getWargaList: $e");
      rethrow; 
    }
  }

// ... di dalam class ApiService ...

  // === AMBIL PROFIL SAYA ===
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/me"), // Panggil endpoint /api/auth/me
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Gagal memuat profil"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // === LOGOUT (HAPUS TOKEN) ===
  static Future<void> logout() async {
    _token = null; // Hapus token dari memori
    // Jika nanti Anda pakai SharedPreferences, hapus juga dari sana
  }


// === AMBIL NOTIFIKASI ===
  static Future<List<dynamic>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/warga/rw/notifications"), // Ganti 10.0.2.2 jika Emulator
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']; // Kembalikan list notifikasi
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // === VERIFIKASI AKUN (RW ACC RT) ===
  static Future<bool> verifyAccount(int idUser) async {
    try {
      final response = await http.put(
        Uri.parse("http://localhost:5000/api/warga/verify/$idUser"), // Ganti localhost jika perlu
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Gagal verifikasi: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error verify: $e");
      return false;
    }
  }

// === UPDATE PROFIL (Password / Email) ===
  static Future<Map<String, dynamic>> updateProfile({
    required String currentPassword,
    String? newEmail,
    String? newUsername,
    String? newPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("http://localhost:5000/api/auth/update"), // Sesuaikan localhost/10.0.2.2
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: jsonEncode({
          "currentPassword": currentPassword, // Wajib
          "email": newEmail,
          "username": newUsername,
          "newPassword": newPassword, // Opsional
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
} 