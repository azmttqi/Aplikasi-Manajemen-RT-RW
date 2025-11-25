import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import pool from "../config/db.js";
import dotenv from "dotenv";
dotenv.config();

/**
 * 🛠️ Fungsi Bantu untuk menangani pendaftaran pengguna
 */
const registerUserByRole = (roleName) => async (req, res) => {
  // Update: Menambahkan 'username' agar bisa disimpan ke database
  const { email, username, password } = req.body;
  
  try {
    // 1. Hash kata sandi
    const hashed = await bcrypt.hash(password, 10);

    // 2. Dapatkan ID peran (id_role)
    const roleRes = await pool.query(
      "SELECT id_role FROM roles WHERE nama_role = $1",
      [roleName]
    );

    if (roleRes.rows.length === 0) {
      return res.status(400).json({ message: `Role '${roleName}' tidak ditemukan.` });
    }

    const id_role = roleRes.rows[0].id_role;

    // 3. Masukkan pengguna baru ke database
    // Pastikan tabel 'pengguna' kamu memiliki kolom 'username'
    // Jika username kosong, kita isi dengan null atau gunakan email sebagai fallback
    const finalUsername = username || email.split('@')[0]; 

    const insertUser = await pool.query(
      "INSERT INTO pengguna (email, username, password_hash, id_role) VALUES ($1, $2, $3, $4) RETURNING *",
      [email, finalUsername, hashed, id_role]
    );

    res.status(201).json({
      message: `Akun ${roleName} berhasil dibuat`,
      user: insertUser.rows[0],
    });

  } catch (err) {
    console.error(`Error saat registrasi ${roleName}:`, err);
    
    if (err.code === '23505') { // Error unique violation (email/username kembar)
        return res.status(409).json({ message: "Email atau Username sudah terdaftar" });
    }
    
    res.status(500).json({ message: `Gagal registrasi ${roleName}` });
  }
};

// 🔹 Export Fungsi Registrasi
export const registerRW = registerUserByRole("RW");
export const registerRT = registerUserByRole("RT");
export const registerWarga = registerUserByRole("Warga");

// 🔹 Login Semua Role (FULL CODE FIX)
export const login = async (req, res) => {
  try {
    // --- DEBUGGING START ---
    console.log("================ LOGIN REQUEST ================");
    console.log("📥 Body dari Frontend:", req.body);
    
    // 1. Tangkap input (bisa berupa identifier, email, atau username)
    const { password, identifier, email, username } = req.body;

    // Prioritas: Identifier -> Username -> Email
    const loginKey = identifier || username || email;

    console.log("🔑 Kunci yang dipakai login:", loginKey);

    // 2. Validasi Input Kosong
    if (!loginKey || !password) {
      console.log("❌ Gagal: Input tidak lengkap");
      return res.status(400).json({ message: "Username/Email dan Password wajib diisi!" });
    }

    // 3. Cari User di Database (Cek Email ATAU Username)
    const userRes = await pool.query(
      "SELECT * FROM pengguna WHERE email = $1 OR username = $1",
      [loginKey]
    );

    const user = userRes.rows[0];

    // Cek apakah user ditemukan
    if (!user) {
      console.log("❌ Gagal: User tidak ditemukan di DB");
      return res.status(404).json({ message: "Akun tidak ditemukan. Cek kembali username/email Anda." });
    }

    console.log("✅ User ditemukan ID:", user.id_pengguna);

    // 4. Verifikasi Password
    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) {
      console.log("❌ Gagal: Password Salah");
      return res.status(401).json({ message: "Password salah" });
    }

    // 5. Generate Token
    const token = jwt.sign(
      {
        id_pengguna: user.id_pengguna,
        id_role: user.id_role,
      },
      process.env.JWT_SECRET,
      { expiresIn: "1d" }
    );

    console.log("🚀 Login SUKSES. Token dikirim.");

    // 6. Kirim Response Sukses
    res.status(200).json({
      message: "Login berhasil",
      token,
      user: {
        id_pengguna: user.id_pengguna,
        email: user.email,
        username: user.username,
        id_role: user.id_role,
      },
    });

  } catch (err) {
    console.error("🔥 ERROR 500 TERJADI:", err);
    res.status(500).json({ 
        message: "Terjadi kesalahan server", 
        error: err.message 
    });
  }
};