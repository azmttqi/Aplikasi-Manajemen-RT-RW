import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import pool from "../config/db.js";
import dotenv from "dotenv";
import nodemailer from 'nodemailer';
dotenv.config();

// ==========================================
// 1. FUNGSI REGISTER (RW, RT, WARGA)
// ==========================================
const registerUserByRole = (roleName) => async (req, res) => {
  const { 
    // Data Akun
    nama_lengkap, email, username, password, 
    
    // Data Wilayah (RW & RT)
    nomor_rw, nomor_rt, alamat, kode_wilayah_baru,

    // Data Validasi
    kode_rw_induk, kode_rt_induk,

    // Data Pribadi Warga
    nik, no_kk, tanggal_lahir
  } = req.body;
  
  const client = await pool.connect();

  try {
    await client.query('BEGIN'); // --- MULAI TRANSAKSI ---

    // 1. Cek Role ID
    const roleRes = await client.query("SELECT id_role FROM roles WHERE nama_role = $1", [roleName]);
    if (roleRes.rows.length === 0) throw new Error(`Role ${roleName} tidak ditemukan`);
    const id_role = roleRes.rows[0].id_role;

    // 2. LOGIKA PER ROLE
    let id_wilayah_induk = null;

    // === JIKA RW ===
    if (roleName === 'RW') {
        if (!nomor_rw || !kode_wilayah_baru) return res.status(400).json({ message: "Nomor RW dan Kode Wilayah wajib diisi!" });
        const cekKode = await client.query("SELECT id_rw FROM wilayah_rw WHERE kode_rw = $1", [kode_wilayah_baru]);
        if(cekKode.rows.length > 0) return res.status(400).json({ message: "Kode Unik Wilayah sudah terpakai!" });
    } 
    // === JIKA RT ===
    else if (roleName === 'RT') {
        if (!kode_rw_induk) return res.status(400).json({ message: "Wajib memasukkan Kode Unik RW!" });
        const rwCheck = await client.query("SELECT id_rw FROM wilayah_rw WHERE kode_rw = $1", [kode_rw_induk]);
        if (rwCheck.rows.length === 0) return res.status(400).json({ message: "Kode RW tidak ditemukan!" });
        
        id_wilayah_induk = rwCheck.rows[0].id_rw;

        const cekKode = await client.query("SELECT id_rt FROM wilayah_rt WHERE kode_rt = $1", [kode_wilayah_baru]);
        if(cekKode.rows.length > 0) return res.status(400).json({ message: "Kode Unik RT sudah terpakai!" });
    }
    // === JIKA WARGA ===
    else if (roleName === 'Warga') {
        if (!kode_rt_induk) return res.status(400).json({ message: "Wajib memasukkan Kode Unik RT!" });

        const rtCheck = await client.query("SELECT id_rt FROM wilayah_rt WHERE kode_rt = $1", [kode_rt_induk]);
        if (rtCheck.rows.length === 0) return res.status(400).json({ message: "Kode RT tidak ditemukan!" });
        
        id_wilayah_induk = rtCheck.rows[0].id_rt;
        
        const cekNik = await client.query("SELECT id_warga FROM warga WHERE nik = $1", [nik]);
        if (cekNik.rows.length > 0) return res.status(400).json({ message: "NIK sudah terdaftar!" });
    }

    // 3. Insert ke Tabel Pengguna
    const checkUser = await client.query("SELECT id_pengguna FROM pengguna WHERE email = $1 OR username = $2", [email, username]);
    if (checkUser.rows.length > 0) {
        await client.query('ROLLBACK');
        return res.status(409).json({ message: "Email atau Username sudah terdaftar." });
    }

    const hashed = await bcrypt.hash(password, 10);
    
    // --- STATUS VERIFIKASI ---
    // Pastikan ID status ini sesuai dengan tabel 'status_verifikasi' di database Anda
    // Biasanya: 1 = Pending, 2 = Disetujui
    let statusId = 1; // Default Pending/Diajukan
    const statusRes = await client.query("SELECT id FROM status_verifikasi WHERE nama = 'Diajukan' OR nama = 'Pending' LIMIT 1");
    if (statusRes.rows.length > 0) statusId = statusRes.rows[0].id;

    const insertUser = await client.query(
      `INSERT INTO pengguna (email, username, password_hash, id_role, status_verifikasi_id) 
       VALUES ($1, $2, $3, $4, $5) RETURNING id_pengguna`,
      [email, username, hashed, id_role, statusId]
    );
    const userId = insertUser.rows[0].id_pengguna;

    // 4. INSERT DATA TAMBAHAN
    if (roleName === 'RW') {
        await client.query(
            `INSERT INTO wilayah_rw (nama_rw, kode_rw, alamat_rw, id_pengguna) 
             VALUES ($1, $2, $3, $4)`,
            [`RW ${nomor_rw}`, kode_wilayah_baru, alamat, userId]
        );
    } else if (roleName === 'RT') {
        await client.query(
            `INSERT INTO wilayah_rt (kode_rt, alamat_rt, id_rw, id_pengguna, nomor_rt) 
             VALUES ($1, $2, $3, $4, $5)`,
            [kode_wilayah_baru, alamat, id_wilayah_induk, userId, nomor_rt]
        );
    } else if (roleName === 'Warga') {
        // PERHATIKAN: Disini status_verifikasi diisi 'pending'
        await client.query(
            `INSERT INTO warga (nama_lengkap, nik, no_kk, tanggal_lahir, id_rt, pengguna_id, status_verifikasi) 
             VALUES ($1, $2, $3, $4, $5, $6, 'pending')`,
            [nama_lengkap, nik, no_kk, tanggal_lahir, id_wilayah_induk, userId]
        );
    }

    await client.query('COMMIT');

    res.status(201).json({
      message: `Registrasi ${roleName} berhasil. Menunggu verifikasi.`,
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
// 2. FUNGSI LOGIN (MODIFIKASI CEK STATUS)
// ==========================================
const login = async (req, res) => {
  try {
    const { password, identifier, email, username } = req.body;
    const loginKey = identifier || username || email;

    if (!loginKey || !password) return res.status(400).json({ message: "Input tidak lengkap!" });

    // Ambil data user beserta role-nya (join jika perlu, atau ambil id_role saja)
    // Disini kita asumsikan status_verifikasi_id ada di tabel pengguna
    const userRes = await pool.query("SELECT * FROM pengguna WHERE email = $1 OR username = $1", [loginKey]);
    const user = userRes.rows[0];

    if (!user) return res.status(404).json({ message: "Akun tidak ditemukan." });

    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) return res.status(401).json({ message: "Password salah" });

    // ============================================================
    // 🛑 CEK STATUS VERIFIKASI SEBELUM BERI TOKEN
    // ============================================================
    // Asumsi: 
    // id_role 2 = RT (Sesuaikan dengan DB Anda)
    // status_verifikasi_id 1 = Pending/Diajukan
    // status_verifikasi_id 2 = Disetujui/Aktif
    // status_verifikasi_id 3 = Ditolak

    if (user.id_role === 2) { // Jika user adalah RT
        if (user.status_verifikasi_id === 1) {
            return res.status(403).json({ 
                message: "Akun RT Anda sedang menunggu verifikasi dari Ketua RW. Silakan hubungi RW setempat." 
            });
        }
        if (user.status_verifikasi_id === 3) {
            return res.status(403).json({ 
                message: "Pendaftaran akun RT Anda ditolak oleh RW." 
            });
        }
    }
    // Tambahkan logika serupa untuk role lain jika diperlukan (misal RW juga perlu verifikasi admin)

    // ============================================================
    // ✅ JIKA STATUS OK, LANJUT BUAT TOKEN
    // ============================================================

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

export const registerRW = registerUserByRole("RW");
export const registerRT = registerUserByRole("RT");
export const registerWarga = registerUserByRole("Warga");
export { login };

// ... (Fungsi getMe, updateProfile, updateDataWarga, getWargaDetailById TETAP SAMA seperti file asli Anda)
// (Copy paste sisa fungsi di bawah ini dari kode asli Anda karena tidak ada perubahan logika di sana)

// ============================================================
// 3. GET ME (PROFIL) - SUDAH DIPERBAIKI (ADD STATUS)
// ============================================================
export const getMe = async (req, res) => {
  try {
    const userId = req.user.id_pengguna;
    
    // 1. Ambil data dasar User
    const userQuery = await pool.query(
      "SELECT email, username, id_role FROM pengguna WHERE id_pengguna = $1", 
      [userId]
    );

    if (userQuery.rows.length === 0) return res.status(404).json({ message: "User tidak ditemukan" });
    
    const userData = userQuery.rows[0];
    
    // 2. Mapping Role ID ke Nama Role
    let roleName = "User";
    if (userData.id_role === 1) roleName = "RW";
    else if (userData.id_role === 2) roleName = "RT";
    else if (userData.id_role === 3) roleName = "Warga";

    // Data Default Response
    let responseData = {
        nama_lengkap: userData.username, // Default kalau belum ada data nama asli
        username: userData.username,
        email: userData.email,
        role: roleName,
        status: "pending", // Default status
        alamat: "Belum diset",
        nomor_wilayah: "Belum Ada",
        kode_unik: "-"
    };

    // 3. Ambil Data Detail Berdasarkan Role
    if (roleName === 'RW') {
        const rwQuery = await pool.query("SELECT nama_rw, kode_rw, alamat_rw FROM wilayah_rw WHERE id_pengguna = $1", [userId]);
        if (rwQuery.rows.length > 0) {
            responseData.nomor_wilayah = rwQuery.rows[0].nama_rw; 
            responseData.kode_unik = rwQuery.rows[0].kode_rw;
            responseData.alamat = rwQuery.rows[0].alamat_rw;
            responseData.status = "verified"; // RW dianggap auto-verified (bisa disesuaikan)
        }
    } 
    else if (roleName === 'RT') {
        const rtQuery = await pool.query("SELECT nomor_rt, kode_rt, alamat_rt FROM wilayah_rt WHERE id_pengguna = $1", [userId]);
        if (rtQuery.rows.length > 0) {
            responseData.nomor_wilayah = rtQuery.rows[0].nomor_rt;
            responseData.kode_unik = rtQuery.rows[0].kode_rt;
            responseData.alamat = rtQuery.rows[0].alamat_rt;
            responseData.status = "verified"; // RT dianggap auto-verified
        }
    } 
    else if (roleName === 'Warga') {
        // --- PERBAIKAN: Tambahkan w.* agar semua data warga terambil ---
        const wargaQuery = await pool.query(
            `SELECT 
                w.*,  -- Ambil SEMUA kolom dari tabel warga (agama, pekerjaan, dll)
                rt.alamat_rt 
             FROM warga w
             LEFT JOIN wilayah_rt rt ON w.id_rt = rt.id_rt
             WHERE w.pengguna_id = $1`, 
            [userId]
        );

        if (wargaQuery.rows.length > 0) {
            const dataWarga = wargaQuery.rows[0];
            
            responseData.nama_lengkap = dataWarga.nama_lengkap;
            responseData.nik = dataWarga.nik;
            responseData.alamat = dataWarga.alamat_rt || "Alamat RT tidak ditemukan";
            responseData.status = dataWarga.status_verifikasi; 

            // --- TAMBAHAN PENTING (Kirim ke Flutter) ---
            // Masukkan data sensus ke dalam responseData supaya Dashboard bisa nge-cek
            responseData.jenis_kelamin = dataWarga.jenis_kelamin;
            responseData.agama = dataWarga.agama;
            responseData.pekerjaan = dataWarga.pekerjaan;
            responseData.status_perkawinan = dataWarga.status_perkawinan;
            responseData.golongan_darah = dataWarga.golongan_darah;
            responseData.kewarganegaraan = dataWarga.kewarganegaraan;
            responseData.tempat_lahir = dataWarga.tempat_lahir;
            responseData.tanggal_lahir = dataWarga.tanggal_lahir;
        }
    }

    // 4. Kirim Response
    res.json({
      success: true,
      data: responseData
    });

  } catch (err) {
    console.error("Error getMe:", err.message);
    res.status(500).json({ message: "Gagal memuat profil" });
  }
};

// ============================================================
// 4. UPDATE PROFIL
// ============================================================
export const updateProfile = async (req, res) => {
  const { email, username, currentPassword, newPassword } = req.body;
  const userId = req.user.id_pengguna;

  console.log("➡️ Request Update Profil dari User ID:", userId);

  try {
    const userResult = await pool.query("SELECT * FROM pengguna WHERE id_pengguna = $1", [userId]);
    const user = userResult.rows[0];

    if (!user) return res.status(404).json({ message: "User tidak ditemukan" });

    const dbPassword = user.password_hash; 

    // Cek Password Lama
    if (dbPassword) {
      if (!currentPassword) return res.status(400).json({ message: "Password lama wajib diisi!" });
      const isMatch = await bcrypt.compare(currentPassword, dbPassword);
      if (!isMatch) return res.status(400).json({ message: "Password lama salah!" });
    }

    // Hash Password Baru
    let finalPassword = dbPassword;
    if (newPassword && newPassword.trim() !== "") {
      const salt = await bcrypt.genSalt(10);
      finalPassword = await bcrypt.hash(newPassword, salt);
    } 
    else if (!dbPassword && (!newPassword || newPassword.trim() === "")) {
      return res.status(400).json({ message: "Akun Anda belum ada password. Mohon isi password baru!" });
    }

    // Update DB
    await pool.query(
      `UPDATE pengguna 
       SET email = $1, username = $2, password_hash = $3 
       WHERE id_pengguna = $4`,
      [email || user.email, username || user.username, finalPassword, userId]
    );

    res.json({ success: true, message: "Profil berhasil diperbarui!" });

  } catch (err) {
    console.error("Update Profil Error:", err.message);
    res.status(500).json({ message: "Gagal mengupdate profil" });
  }
};

// ============================================================
// 5. UPDATE DATA PRIBADI WARGA (Lengkapi Data Sensus)
// ============================================================
export const updateDataWarga = async (req, res) => {
  // Ambil ID dari token (req.user diset oleh middleware verifyToken)
  const userId = req.user.id_pengguna; 

  // Ambil data dari body request
  const { 
    tempat_lahir, 
    tanggal_lahir, 
    jenis_kelamin, 
    agama, 
    pekerjaan, 
    status_perkawinan, 
    golongan_darah 
  } = req.body;

  try {
    // --- PASTIKAN TIDAK ADA KODE IF (req.user.role !== 'RT') DISINI ---
    
    // Query update database
    const query = `
      UPDATE warga 
      SET 
        tempat_lahir = COALESCE($1, tempat_lahir),
        tanggal_lahir = COALESCE($2, tanggal_lahir),
        jenis_kelamin = COALESCE($3, jenis_kelamin),
        agama = COALESCE($4, agama),
        pekerjaan = COALESCE($5, pekerjaan),
        status_perkawinan = COALESCE($6, status_perkawinan),
        golongan_darah = COALESCE($7, golongan_darah)
      WHERE pengguna_id = $8
      RETURNING *
    `;

    const result = await pool.query(query, [
      tempat_lahir, 
      tanggal_lahir, 
      jenis_kelamin, 
      agama, 
      pekerjaan, 
      status_perkawinan, 
      golongan_darah, 
      userId
    ]);

    if (result.rowCount === 0) {
      return res.status(404).json({ message: "Data warga tidak ditemukan." });
    }

    res.json({ 
      success: true, 
      message: "Data berhasil disimpan!",
      data: result.rows[0]
    });

  } catch (err) {
    console.error("Error updateDataWarga:", err.message);
    res.status(500).json({ message: "Gagal menyimpan data." });
  }
};

// ============================================================
// 6. GET DETAIL WARGA (KHUSUS UNTUK RT MELIHAT WARGA)
// ============================================================
export const getWargaDetailById = async (req, res) => {
  // ID Warga yang mau dilihat (dikirim via URL)
  const { id_warga } = req.params; 
  const userRequesting = req.user; 

  try {
    // 1. Cek apakah yang minta data adalah RT (ID Role 2)
    if (userRequesting.id_role !== 2) {
        return res.status(403).json({ message: "Hanya Pak RT yang boleh lihat detail ini." });
    }

    // 2. Ambil Data Lengkap (Join Table)
    const query = `
      SELECT 
        w.*,               
        p.email,           
        p.username,
        rt.nomor_rt,       
        rw.nama_rw         
      FROM warga w
      JOIN pengguna p ON w.pengguna_id = p.id_pengguna
      JOIN wilayah_rt rt ON w.id_rt = rt.id_rt
      JOIN wilayah_rw rw ON rt.id_rw = rw.id_rw
      WHERE w.id_warga = $1
    `;

    const result = await pool.query(query, [id_warga]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Warga tidak ditemukan." });
    }

    res.json({
      success: true,
      data: result.rows[0]
    });

  } catch (err) {
    console.error("Error getWargaDetail:", err.message);
    res.status(500).json({ message: "Server Error" });
  }
};
// ============================================================
// 7. FORGOT PASSWORD (KIRIM EMAIL RESET)
// ============================================================
export const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    // 1. Cek apakah email terdaftar di database
    const userCheck = await pool.query("SELECT * FROM pengguna WHERE email = $1", [email]);
    if (userCheck.rows.length === 0) {
      return res.status(404).json({ message: "Email tidak ditemukan." });
    }

    // 2. Konfigurasi Nodemailer (Tukang Pos)
    // Ini mengambil data dari file .env yang baru saja kamu update
    const transporter = nodemailer.createTransport({
      host: process.env.MAIL_HOST,       // smtp.googlemail.com
      port: process.env.MAIL_PORT,       // 465
      secure: false,                      // true (karena port 465 SSL)
      auth: {
        user: process.env.MAIL_USERNAME, // Email kamu
        pass: process.env.MAIL_PASSWORD  // App Password 16 digit kamu
      },
      tls: {
          rejectUnauthorized: false // Tambahan: Supaya tidak error sertifikat di Docker
      }
    });

    // 3. Siapkan Isi Email
    // (Di aplikasi asli, biasanya di sini kita buat token unik. Ini contoh simulasi link)
    const resetLink = `http://localhost:5000/api/auth/reset-password-page?email=${email}`; 

    const mailOptions = {
      from: `"${process.env.MAIL_FROM_NAME}" <${process.env.MAIL_FROM_ADDRESS}>`,
      to: email,
      subject: 'Permintaan Reset Password - Manajemen RT/RW',
      text: `Halo,\n\nKami menerima permintaan untuk mereset password akun Anda.\nSilakan klik tautan berikut:\n\n${resetLink}\n\nJika ini bukan Anda, abaikan saja.`,
      html: `
        <h3>Halo, Warga!</h3>
        <p>Kami menerima permintaan reset password.</p>
        <p>Klik tombol di bawah untuk memproses (Simulasi):</p>
        <a href="${resetLink}" style="background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Reset Password</a>
      `
    };

    // 4. Kirim Email
    await transporter.sendMail(mailOptions);

    console.log(`✅ Email reset berhasil dikirim ke: ${email}`);
    res.status(200).json({ message: "Tautan reset berhasil dikirim! Silakan cek email Anda." });

  } catch (error) {
    console.error("❌ Gagal kirim email:", error);
    res.status(500).json({ message: "Gagal mengirim email.", error: error.message });
  }
};

// ============================================================
// 8. HALAMAN RESET PASSWORD (HTML)
// ============================================================
export const getResetPasswordPage = (req, res) => {
  const { email } = req.query;

  res.send(`
    <!DOCTYPE html>
    <html lang="id">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Reset Kata Sandi - Manajemen RT/RW</title>
      <style>
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          background-color: #f4f7f6;
          display: flex;
          justify-content: center;
          align-items: center;
          height: 100vh;
          margin: 0;
        }
        .card {
          background: white;
          padding: 40px;
          border-radius: 12px;
          box-shadow: 0 4px 20px rgba(0,0,0,0.1);
          width: 100%;
          max-width: 400px;
          text-align: center;
        }
        .logo {
          width: 80px;
          margin-bottom: 20px;
        }
        h2 {
          color: #2E7D32; /* Hijau Tua mirip aplikasi */
          margin-bottom: 10px;
        }
        p {
          color: #666;
          font-size: 14px;
          margin-bottom: 30px;
        }
        .input-group {
          margin-bottom: 20px;
          text-align: left;
        }
        label {
          display: block;
          margin-bottom: 8px;
          color: #333;
          font-weight: bold;
          font-size: 14px;
        }
        input[type="password"] {
          width: 100%;
          padding: 12px;
          border: 1px solid #ccc;
          border-radius: 8px;
          box-sizing: border-box; /* Agar padding tidak melebarkan input */
          font-size: 16px;
          transition: border-color 0.3s;
        }
        input[type="password"]:focus {
          border-color: #2E7D32;
          outline: none;
        }
        button {
          width: 100%;
          padding: 14px;
          background-color: #2E7D32;
          color: white;
          border: none;
          border-radius: 8px;
          font-size: 16px;
          font-weight: bold;
          cursor: pointer;
          transition: background-color 0.3s;
        }
        button:hover {
          background-color: #1B5E20;
        }
        .footer {
          margin-top: 20px;
          font-size: 12px;
          color: #aaa;
        }
      </style>
    </head>
    <body>
      <div class="card">
        <img src="https://cdn-icons-png.flaticon.com/512/609/609803.png" alt="Logo Rumah" class="logo"/>
        
        <h2>Atur Ulang Kata Sandi</h2>
        <p>Silakan masukkan kata sandi baru untuk akun <strong>${email}</strong></p>
        
        <form action="/api/auth/reset-password-process" method="POST">
          <input type="hidden" name="email" value="${email}" />
          
          <div class="input-group">
            <label>Kata Sandi Baru</label>
            <input type="password" name="newPassword" required placeholder="Minimal 6 karakter" />
          </div>

          <button type="submit">Simpan Kata Sandi</button>
        </form>

        <div class="footer">
          &copy; 2025 Lingkar Warga App
        </div>
      </div>
    </body>
    </html>
  `);
};
// ============================================================
// 9. PROSES SIMPAN PASSWORD BARU
// ============================================================
export const resetPasswordProcess = async (req, res) => {
  // Karena form HTML mengirim data sebagai form-urlencoded, bukan JSON, 
  // pastikan app.js punya app.use(express.urlencoded({ extended: true }));
  // Tapi untuk amannya kita anggap user kirim JSON atau kita handle manual.
  
  const { email, newPassword } = req.body;

  try {
    if (!newPassword || !email) return res.send("<h1>Error: Data tidak lengkap.</h1>");

    // 1. Hash Password Baru
    // (Kita butuh bcrypt, pastikan sudah di-import di atas. Kalau pakai bcryptjs sesuaikan)
    // import bcrypt from 'bcrypt'; <-- Pastikan ini ada di paling atas file
    // Tetapi karena di file ini Anda pakai bcrypt, kita gunakan langsung.
    // Jika 'bcrypt' belum diimport di file ini, tambahkan importnya.
    
    // Anggap bcrypt sudah diimport (karena dipakai di fungsi register/login)
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    // 2. Update Database
    await pool.query("UPDATE pengguna SET password_hash = $1 WHERE email = $2", [hashedPassword, email]);

    res.send(`
      <div style="text-align:center; padding: 50px;">
        <h1 style="color: green;">Berhasil! 🎉</h1>
        <p>Password Anda telah diperbarui.</p>
        <p>Silakan kembali ke aplikasi dan Login.</p>
      </div>
    `);

  } catch (error) {
    console.error(error);
    res.send("<h1>Terjadi kesalahan server.</h1>");
  }
};