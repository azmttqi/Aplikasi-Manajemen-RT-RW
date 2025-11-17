// src/controllers/authController.js
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import pool from "../config/db.js";
import dotenv from "dotenv";
dotenv.config();

/**
 * 🛠️ Fungsi Bantu untuk menangani pendaftaran pengguna berdasarkan peran (role) tertentu
 * @param {string} roleName - Nama peran ('RW', 'RT', atau 'Warga')
 */
const registerUserByRole = (roleName) => async (req, res) => {
  const { email, password } = req.body;
  try {
    // 1. Hash kata sandi
    const hashed = await bcrypt.hash(password, 10);

    // 2. Dapatkan ID peran (id_role)
    const roleRes = await pool.query(
      "SELECT id_role FROM roles WHERE nama_role = $1",
      [roleName]
    );

    // Cek dasar jika peran tidak ditemukan
    if (roleRes.rows.length === 0) {
      return res.status(400).json({ message: `Role '${roleName}' tidak ditemukan.` });
    }

    const id_role = roleRes.rows[0].id_role;

    // 3. Masukkan pengguna baru ke database
    const insertUser = await pool.query(
      "INSERT INTO pengguna (email, password_hash, id_role) VALUES ($1,$2,$3) RETURNING *",
      [email, hashed, id_role]
    );

    res.status(201).json({
      message: `Akun ${roleName} berhasil dibuat`,
      user: insertUser.rows[0],
    });
  } catch (err) {
    console.error(`Error saat registrasi ${roleName}:`, err);
    
    // Penanganan error duplikasi email (asumsi ada UNIQUE constraint pada email)
    if (err.code === '23505') { // Kode error unik violation PostgreSQL
        return res.status(409).json({ message: "Email sudah terdaftar" });
    }
    
    res.status(500).json({ message: `Gagal registrasi ${roleName}` });
  }
};

// 🔹 Registrasi RW (sekarang menggunakan fungsi bantu)
export const registerRW = registerUserByRole("RW");

// 🔹 Registrasi RT (sekarang menggunakan fungsi bantu)
export const registerRT = registerUserByRole("RT");

// 🔹 Registrasi Warga (sekarang menggunakan fungsi bantu)
export const registerWarga = registerUserByRole("Warga");

// 🔹 Login Semua Role
export const login = async (req, res) => {
  const { identifier, password } = req.body; // <= BUKAN "email" lagi

  console.log("identifier : ", identifier);
  try {
    const userRes = await pool.query(
      "SELECT * FROM pengguna WHERE email = $1 OR username = $1",
      [identifier]
    );

    const user = userRes.rows[0];

    console.log("user : ", user);
    if (!user) {
      return res.status(400).json({ message: "Email / Username tidak ditemukan" });
    }

    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) {
      return res.status(401).json({ message: "Password salah" });
    }

    const token = jwt.sign(
      {
        id_pengguna: user.id_pengguna,
        id_role: user.id_role,
      },
      process.env.JWT_SECRET,
      { expiresIn: "1d" }
    );

    res.status(200).json({
      message: "Login berhasil",
      token,
      user: {
        id_pengguna: user.id_pengguna,
        email: user.email,
        username: user.username,    // <= kalau mau dipakai di frontend
        id_role: user.id_role,
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Login gagal" });
  }
};
