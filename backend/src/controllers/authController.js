import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import pool from "../config/db.js";
import dotenv from "dotenv";
dotenv.config();

const registerUserByRole = (roleName) => async (req, res) => {
  // Kita terima data LENGKAP dari Frontend sesuai desain
  const { 
    // Data Akun (Semua Role)
    nama_lengkap, email, username, password, 
    
    // Data Wilayah (Khusus RW & RT)
    nomor_rw, // ex: "05"
    nomor_rt, // ex: "01"
    alamat,   // Alamat sekretariat/wilayah
    kode_wilayah_baru, // Kode unik yang DIBUAT oleh RW/RT untuk wilayahnya

    // Data Validasi (Tiket Masuk)
    kode_rw_induk, // Diisi RT saat daftar (Kode milik RW)
    kode_rt_induk, // Diisi Warga saat daftar (Kode milik RT)

    // Data Pribadi Warga (Khusus Warga)
    nik, no_kk, tanggal_lahir
  } = req.body;
  
  const client = await pool.connect();

  try {
    await client.query('BEGIN'); // --- MULAI TRANSAKSI ---

    // 1. Cek Role ID
    const roleRes = await client.query("SELECT id_role FROM roles WHERE nama_role = $1", [roleName]);
    if (roleRes.rows.length === 0) {
      throw new Error(`Role ${roleName} tidak ditemukan`);
    }
    const id_role = roleRes.rows[0].id_role;

    // 2. LOGIKA PER ROLE (Sesuai Desain Frontend)
    let id_wilayah_induk = null; // ID RW (untuk RT) atau ID RT (untuk Warga)

    // === JIKA RW ===
    if (roleName === 'RW') {
        // RW wajib isi data wilayah
        if (!nomor_rw || !kode_wilayah_baru) {
             return res.status(400).json({ message: "Nomor RW dan Kode Wilayah wajib diisi!" });
        }
        // Cek apakah Kode Wilayah sudah dipakai orang lain
        const cekKode = await client.query("SELECT id_rw FROM wilayah_rw WHERE kode_rw = $1", [kode_wilayah_baru]);
        if(cekKode.rows.length > 0) return res.status(400).json({ message: "Kode Unik Wilayah sudah terpakai!" });
    } 
    
    // === JIKA RT ===
    else if (roleName === 'RT') {
        // RT wajib masukkan Kode RW Induk (Validasi)
        if (!kode_rw_induk) return res.status(400).json({ message: "Wajib memasukkan Kode Unik RW!" });
        
        // Cek Kode RW Induk
        const rwCheck = await client.query("SELECT id_rw FROM wilayah_rw WHERE kode_rw = $1", [kode_rw_induk]);
        if (rwCheck.rows.length === 0) return res.status(400).json({ message: "Kode RW tidak ditemukan!" });
        
        id_wilayah_induk = rwCheck.rows[0].id_rw; // Simpan ID RW

        // Cek Kode Wilayah Baru (yang dibuat RT untuk warganya nanti)
        const cekKode = await client.query("SELECT id_rt FROM wilayah_rt WHERE kode_rt = $1", [kode_wilayah_baru]);
        if(cekKode.rows.length > 0) return res.status(400).json({ message: "Kode Unik RT sudah terpakai!" });
    }

    // === JIKA WARGA ===
    else if (roleName === 'Warga') {
        // Warga wajib masukkan Kode RT Induk
        if (!kode_rt_induk) return res.status(400).json({ message: "Wajib memasukkan Kode Unik RT!" });

        // Cek Kode RT Induk
        const rtCheck = await client.query("SELECT id_rt FROM wilayah_rt WHERE kode_rt = $1", [kode_rt_induk]);
        if (rtCheck.rows.length === 0) return res.status(400).json({ message: "Kode RT tidak ditemukan!" });
        
        id_wilayah_induk = rtCheck.rows[0].id_rt; // Simpan ID RT
        
        // Cek NIK Unik
        const cekNik = await client.query("SELECT id_warga FROM warga WHERE nik = $1", [nik]);
        if (cekNik.rows.length > 0) return res.status(400).json({ message: "NIK sudah terdaftar!" });
    }

    // 3. Insert ke Tabel Pengguna (Akun Login)
    // Cek duplikat email/username
    const checkUser = await client.query("SELECT id_pengguna FROM pengguna WHERE email = $1 OR username = $2", [email, username]);
    if (checkUser.rows.length > 0) {
        await client.query('ROLLBACK');
        return res.status(409).json({ message: "Email atau Username sudah terdaftar." });
    }

    const hashed = await bcrypt.hash(password, 10);
    // Ambil status default (ID 1 = Diajukan)
    let statusId = 1; 
    const statusRes = await client.query("SELECT id FROM status_verifikasi WHERE nama = 'Diajukan' LIMIT 1");
    if (statusRes.rows.length > 0) statusId = statusRes.rows[0].id;

    const insertUser = await client.query(
      `INSERT INTO pengguna (email, username, password_hash, id_role, status_verifikasi_id) 
       VALUES ($1, $2, $3, $4, $5) RETURNING id_pengguna`,
      [email, username, hashed, id_role, statusId]
    );
    const userId = insertUser.rows[0].id_pengguna;

    // 4. INSERT DATA TAMBAHAN (Sesuai Desain)

    if (roleName === 'RW') {
        // Insert Data Wilayah RW
        await client.query(
            `INSERT INTO wilayah_rw (nama_rw, kode_rw, alamat_rw, id_pengguna) 
             VALUES ($1, $2, $3, $4)`,
            [`RW ${nomor_rw}`, kode_wilayah_baru, alamat, userId]
        );

    } else if (roleName === 'RT') {
        // Insert Data Wilayah RT (Link ke RW Induk)
        await client.query(
            `INSERT INTO wilayah_rt (kode_rt, alamat_rt, id_rw, id_pengguna) 
             VALUES ($1, $2, $3, $4)`,
            [kode_wilayah_baru, alamat, id_wilayah_induk, userId]
        );

    } else if (roleName === 'Warga') {
        // Insert Data Warga Lengkap (Link ke RT Induk)
        await client.query(
            `INSERT INTO warga (nama_lengkap, nik, no_kk, tanggal_lahir, id_rt, pengguna_id, status_verifikasi) 
             VALUES ($1, $2, $3, $4, $5, $6, 'pending')`,
            [nama_lengkap, nik, no_kk, tanggal_lahir, id_wilayah_induk, userId]
        );
    }

    await client.query('COMMIT'); // Simpan Permanen

    res.status(201).json({
      message: `Registrasi ${roleName} berhasil`,
      user: { email, username, role: roleName }
    });

  } catch (err) {
    await client.query('ROLLBACK');
    console.error(`Register Error:`, err);
    res.status(500).json({ message: "Terjadi kesalahan server", error: err.message });
  } finally {
    client.release();
  }
};

// ==========================================
// 2. FUNGSI LOGIN (SAMA SEPERTI SEBELUMNYA)
// ==========================================
const login = async (req, res) => {
  try {
    const { password, identifier, email, username } = req.body;
    const loginKey = identifier || username || email;

    if (!loginKey || !password) return res.status(400).json({ message: "Input tidak lengkap!" });

    const userRes = await pool.query("SELECT * FROM pengguna WHERE email = $1 OR username = $1", [loginKey]);
    const user = userRes.rows[0];

    if (!user) return res.status(404).json({ message: "Akun tidak ditemukan." });

    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) return res.status(401).json({ message: "Password salah" });

    const token = jwt.sign(
      { id_pengguna: user.id_pengguna, id_role: user.id_role },
      process.env.JWT_SECRET,
      { expiresIn: "1d" }
    );

    res.status(200).json({
      message: "Login berhasil",
      token,
      user: { id: user.id_pengguna, email: user.email, role: user.id_role }
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server Error" });
  }
};

// Export Function
export const registerRW = registerUserByRole("RW");
export const registerRT = registerUserByRole("RT");
export const registerWarga = registerUserByRole("Warga");
export { login };

// getMe

export const getMe = async (req, res) => {
  try {
    const userId = req.user.id_pengguna;
    
    // 1. QUERY DIPERBAIKI: 
    // - Hapus 'nama_lengkap' (Ganti jadi ambil username)
    // - Ganti 'role' jadi 'id_role' (Sesuai nama kolom di DB)
    const userQuery = await pool.query(
      "SELECT email, username, id_role FROM pengguna WHERE id_pengguna = $1", 
      [userId]
    );

    if (userQuery.rows.length === 0) return res.status(404).json({ message: "User tidak ditemukan" });
    
    const userData = userQuery.rows[0];
    
    // 2. Mapping Role ID ke Nama Role (Agar di Frontend muncul "RW", bukan "1")
    let roleName = "User";
    if (userData.id_role === 1) roleName = "RW";
    else if (userData.id_role === 2) roleName = "RT";
    else if (userData.id_role === 3) roleName = "Warga";

    let wilayahData = {
        nomor_wilayah: "Belum Ada", 
        kode_unik: "-"
    };

    // 3. Ambil Data Wilayah (Gunakan roleName yang sudah di-mapping)
    if (roleName === 'RW') {
        const rwQuery = await pool.query("SELECT nama_rw, kode_rw FROM wilayah_rw WHERE id_pengguna = $1", [userId]);
        if (rwQuery.rows.length > 0) {
            wilayahData = {
                nomor_wilayah: rwQuery.rows[0].nama_rw, 
                kode_unik: rwQuery.rows[0].kode_rw
            };
        }
    } else if (roleName === 'RT') {
        const rtQuery = await pool.query("SELECT kode_rt FROM wilayah_rt WHERE id_pengguna = $1", [userId]);
        if (rtQuery.rows.length > 0) {
            wilayahData = {
                nomor_wilayah: "RT " + rtQuery.rows[0].kode_rt,
                kode_unik: "-" 
            };
        }
    }

    // 4. Kirim Response (Mapping username jadi nama_lengkap agar Frontend tidak error)
    res.json({
      success: true,
      data: {
        nama_lengkap: userData.username, // <--- PENTING: Pakai username sebagai nama
        username: userData.username,
        email: userData.email,
        role: roleName, // Kirim "RW"/"RT" ke frontend
        ...wilayahData
      }
    });

  } catch (err) {
    console.error("Error getMe:", err.message);
    res.status(500).json({ message: "Gagal memuat profil" });
  }
};