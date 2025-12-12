// src/controllers/wargaController.js
import pool from "../config/db.js";

/* ============================================================
   ➕ TAMBAH WARGA (VERSI FIX & DEBUG)
============================================================ */
export const addWarga = async (req, res) => {
  // 1. Debugging: Cek data apa yang dikirim Frontend
  console.log("🔥 [DEBUG] Request Body:", req.body);
  console.log("👤 [DEBUG] User Login:", req.user);

  let { nama_lengkap, nik, no_kk, id_rt } = req.body;

  try {
    // 2. LOGIKA OTOMATIS: Jika id_rt kosong, ambil dari user yang login (RT)
    if (!id_rt) {
      console.log("⚠️ id_rt tidak dikirim frontend, mencoba ambil dari User Login...");
      
      const userId = req.user.id_pengguna;
      
      // Cari RT ID berdasarkan user login
      const rtCheck = await pool.query(
        "SELECT id_rt FROM wilayah_rt WHERE id_pengguna = $1", 
        [userId]
      );

      if (rtCheck.rows.length > 0) {
        id_rt = rtCheck.rows[0].id_rt;
        console.log("✅ Berhasil mendeteksi id_rt otomatis:", id_rt);
      } else {
        // Jika user bukan RT dan tidak kirim id_rt, maka error
        console.error("❌ User bukan Ketua RT dan tidak mengirim id_rt manual.");
        return res.status(400).json({ 
            message: "Gagal: id_rt tidak ditemukan. Pastikan Anda login sebagai RT atau kirim id_rt." 
        });
      }
    }

    // 3. Eksekusi Simpan ke Database
    const result = await pool.query(
      `INSERT INTO warga (nama_lengkap, nik, no_kk, id_rt, status_verifikasi)
       VALUES ($1, $2, $3, $4, 'pending')
       RETURNING *`,
      [nama_lengkap, nik, no_kk, id_rt]
    );

    console.log("✅ Sukses simpan ke DB:", result.rows[0]);

    res.status(201).json({
      message: "✅ Data warga berhasil ditambahkan",
      data: result.rows[0],
    });

  } catch (err) {
    console.error("❌ Gagal menambahkan warga (SQL Error):", err.message);
    
    // Cek error spesifik (misal NIK duplikat)
    if (err.code === '23505') { // Kode error Postgres untuk Unique Constraint
        return res.status(400).json({ message: "Gagal: NIK sudah terdaftar sebelumnya." });
    }

    res.status(500).json({ message: "Gagal menambahkan warga", error: err.message });
  }
};

/* ============================================================
   📋 LIHAT SEMUA WARGA
============================================================ */
export const getAllWarga = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT w.nama_lengkap, w.nik, w.no_kk, w.id_rt, w.status_verifikasi, rt.kode_rt
       FROM warga w
       LEFT JOIN wilayah_rt rt ON w.id_rt = rt.id_rt
       ORDER BY rt.kode_rt, w.nama_lengkap ASC`
    );
    res.json({ message: "Daftar warga berhasil diambil", data: result.rows });
  } catch (err) {
    console.error("❌ Gagal mengambil warga:", err.message);
    res.status(500).json({ message: "Gagal mengambil data warga", error: err.message });
  }
};

/* ============================================================
   ✏️ UPDATE DATA WARGA (berdasarkan NIK)
============================================================ */
export const updateWarga = async (req, res) => {
  const { nik } = req.params;
  const { nama_lengkap, no_kk, status_verifikasi } = req.body;

  try {
    const result = await pool.query(
      `UPDATE warga
       SET nama_lengkap = COALESCE($1, nama_lengkap),
           no_kk = COALESCE($2, no_kk),
           status_verifikasi = COALESCE($3, status_verifikasi)
       WHERE nik = $4
       RETURNING *`,
      [nama_lengkap, no_kk, status_verifikasi, nik]
    );

    if (result.rowCount === 0)
      return res.status(404).json({ message: "Warga tidak ditemukan" });

    res.json({ message: "Data warga berhasil diperbarui", data: result.rows[0] });
  } catch (err) {
    console.error("❌ Gagal update warga:", err.message);
    res.status(500).json({ message: "Gagal memperbarui data warga", error: err.message });
  }
};

/* ============================================================
   ❌ HAPUS WARGA TOTAL (Hapus Biodata + Akun Login)
============================================================ */
export const deleteWarga = async (req, res) => {
  const { id } = req.params; // id_warga

  const client = await pool.connect(); // Pakai client untuk transaksi

  try {
    await client.query('BEGIN'); // Mulai Transaksi

    // 1. Cari dulu ID Pengguna (Akun Login) milik warga ini
    const checkQuery = "SELECT pengguna_id FROM warga WHERE id_warga = $1";
    const checkResult = await client.query(checkQuery, [id]);

    if (checkResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ message: "Warga tidak ditemukan" });
    }

    const idPengguna = checkResult.rows[0].pengguna_id;

    // 2. Hapus Data Biodata di tabel 'warga'
    await client.query("DELETE FROM warga WHERE id_warga = $1", [id]);

    // 3. Hapus Akun Login di tabel 'pengguna' (Jika ada)
    if (idPengguna) {
      await client.query("DELETE FROM pengguna WHERE id_pengguna = $1", [idPengguna]);
    }

    await client.query('COMMIT'); // Simpan perubahan permanen

    res.json({ 
      success: true, 
      message: "Data warga dan akun login berhasil dihapus permanen." 
    });

  } catch (err) {
    await client.query('ROLLBACK'); // Batalkan jika ada error
    console.error("Delete Error:", err.message);
    res.status(500).json({ message: "Gagal menghapus data warga" });
  } finally {
    client.release();
  }
};

/* ============================================================
   👀 WARGA PENDING UNTUK RT LOGIN (FIX: TAMBAH id_warga)
============================================================ */
export const getPendingWargaForRT = async (req, res) => {
  try {
    const userId = req.user.id_pengguna;

    const rtRes = await pool.query(
      "SELECT id_rt FROM wilayah_rt WHERE id_pengguna = $1",
      [userId]
    );
    const id_rt = rtRes.rows[0]?.id_rt;
    if (!id_rt) return res.status(400).json({ message: "RT belum terkait wilayah" });

    const result = await pool.query(
      `SELECT 
          id_warga,  -- <--- INI PENTING! JANGAN SAMPAI LUPA
          nama_lengkap, 
          nik, 
          no_kk, 
          id_rt,
          status_verifikasi
       FROM warga
       WHERE id_rt = $1 AND status_verifikasi = 'pending'
       ORDER BY nama_lengkap ASC`,
      [id_rt]
    );

    res.json({ message: "Daftar warga pending berhasil diambil", data: result.rows });
  } catch (err) {
    console.error("❌ Error getPendingWargaForRT:", err.message);
    res.status(500).json({ message: "Gagal mengambil warga pending", error: err.message });
  }
};

/* ============================================================
   👁️ SEMUA WARGA PENDING (ADMIN)
============================================================ */
export const getPendingWarga = async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM warga WHERE status_verifikasi = 'pending'");
    res.status(200).json({ message: "Daftar warga pending berhasil diambil", data: result.rows });
  } catch (error) {
    console.error("❌ Error getPendingWarga:", error.message);
    res.status(500).json({ message: "Gagal mengambil warga pending" });
  }
};

/* ============================================================
   📋 WARGA DALAM RW YANG LOGIN
============================================================ */
export const getAllWargaByRW = async (req, res) => {
  try {
    const userId = req.user.id_pengguna;
    const rwRes = await pool.query("SELECT id_rw FROM wilayah_rw WHERE id_pengguna = $1", [userId]);
    if (rwRes.rowCount === 0)
      return res.status(400).json({ message: "RW belum memiliki wilayah terdaftar" });

    const id_rw = rwRes.rows[0].id_rw;
    const wargaRes = await pool.query(
      `SELECT w.nama_lengkap, w.nik, w.no_kk, w.status_verifikasi, rt.kode_rt
       FROM warga w
       JOIN wilayah_rt rt ON w.id_rt = rt.id_rt
       WHERE rt.id_rw = $1
       ORDER BY rt.kode_rt, w.nama_lengkap`,
      [id_rw]
    );

    res.json({ message: "Daftar warga dalam RW berhasil diambil", data: wargaRes.rows });
  } catch (err) {
    console.error("❌ Gagal mengambil daftar warga RW:", err.message);
    res.status(500).json({ message: "Gagal mengambil data warga RW", error: err.message });
  }
};

/* ============================================================
   📊 STATISTIK WARGA PER RW
============================================================ */
export const getStatistikWargaByRW = async (req, res) => {
  try {
    const userId = req.user.id_pengguna;
    const rwRes = await pool.query("SELECT id_rw FROM wilayah_rw WHERE id_pengguna = $1", [userId]);
    const id_rw = rwRes.rows[0]?.id_rw;
    if (!id_rw)
      return res.status(400).json({ message: "RW belum memiliki wilayah terdaftar" });

    const statistik = await pool.query(
      `SELECT
          COUNT(*) AS total_warga,
          COUNT(*) FILTER (WHERE w.status_verifikasi = 'pending') AS pending,
          COUNT(*) FILTER (WHERE w.status_verifikasi = 'disetujui') AS disetujui,
          COUNT(*) FILTER (WHERE w.status_verifikasi = 'ditolak') AS ditolak
       FROM warga w
       JOIN wilayah_rt rt ON w.id_rt = rt.id_rt
       WHERE rt.id_rw = $1`,
      [id_rw]
    );

    res.json({
      message: "Statistik warga RW berhasil diambil",
      data: statistik.rows[0],
    });
  } catch (err) {
    console.error("❌ Gagal mengambil statistik RW:", err.message);
    res.status(500).json({ message: "Gagal mengambil statistik warga RW", error: err.message });
  }
};

/* ============================================================
   🧭 DASHBOARD RW
============================================================ */
export const getDashboardRW = async (req, res) => {
  try {
    const id_pengguna = req.user.id_pengguna;
    const rwResult = await pool.query(
      "SELECT id_rw, nama_rw FROM wilayah_rw WHERE id_pengguna = $1",
      [id_pengguna]
    );

    if (rwResult.rowCount === 0)
      return res.status(404).json({ message: "RW belum memiliki wilayah terdaftar" });

    const id_rw = rwResult.rows[0].id_rw;
    const rtResult = await pool.query("SELECT COUNT(*) FROM wilayah_rt WHERE id_rw = $1", [id_rw]);
    const wargaResult = await pool.query(
      `SELECT
        COUNT(*) AS total_warga,
        COUNT(*) FILTER (WHERE status_verifikasi = 'disetujui') AS disetujui,
        COUNT(*) FILTER (WHERE status_verifikasi = 'pending') AS pending,
        COUNT(*) FILTER (WHERE status_verifikasi = 'ditolak') AS ditolak
       FROM warga w
       JOIN wilayah_rt rt ON w.id_rt = rt.id_rt
       WHERE rt.id_rw = $1`,
      [id_rw]
    );

    res.status(200).json({
      message: "Dashboard RW berhasil diambil",
      data: {
        nama_rw: rwResult.rows[0].nama_rw,
        jumlah_rt: rtResult.rows[0].count,
        ...wargaResult.rows[0],
      },
    });
  } catch (err) {
    console.error("❌ Gagal mengambil dashboard RW:", err.message);
    res.status(500).json({ message: "Gagal mengambil dashboard RW", error: err.message });
  }
};

/* ============================================================
   🔍 GET DATA LIST (FIX FINAL: Filter Disetujui + No Alamat)
============================================================ */
export const getDataList = async (req, res) => {
  try {
    const userId = req.user.id_pengguna; 
    const { search } = req.query; 
    
    // 1. DEKLARASI VARIABEL (Supaya tidak error "query is not defined")
    let query = ""; 
    let params = [];

    // 2. Cek Apakah RW?
    const rwCheck = await pool.query("SELECT id_rw FROM wilayah_rw WHERE id_pengguna = $1", [userId]);
    
    if (rwCheck.rows.length > 0) {
      const idRw = rwCheck.rows[0].id_rw;
      params.push(idRw); 

      // QUERY RW
      query = `
        SELECT 
            rt.id_rt AS id,  
            rt.kode_rt AS nomor_rt,       
            rt.alamat_rt,
            u.username AS nama_ketua_rt, 
            u.email,
            u.status_verifikasi_id,
            (SELECT COUNT(*) FROM warga w WHERE w.id_rt = rt.id_rt AND w.status_verifikasi ILIKE 'disetujui') AS jumlah_warga
        FROM wilayah_rt rt
        LEFT JOIN pengguna u ON rt.id_pengguna = u.id_pengguna
        WHERE rt.id_rw = $1
      `;

      if (search) {
        query += ` AND (u.username ILIKE $2 OR rt.kode_rt ILIKE $2)`;
        params.push(`%${search}%`);
      }
      
      query += " ORDER BY rt.kode_rt ASC"; 
    } 
    
    // 3. Cek Apakah RT?
    else {
      const rtCheck = await pool.query("SELECT id_rt FROM wilayah_rt WHERE id_pengguna = $1", [userId]);
      
      if (rtCheck.rows.length > 0) {
        const idRt = rtCheck.rows[0].id_rt;
        params.push(idRt); 
        
        // QUERY RT (FILTER AKTIF)
        query = `
          SELECT 
            w.id_warga AS id, 
            w.nama_lengkap, 
            w.nik, 
            w.no_kk, 
            -- w.alamat,  <-- SAYA HAPUS KARENA ERROR COLUMN NOT EXIST
            w.status_verifikasi 
          FROM warga w
          WHERE w.id_rt = $1 
          -- FILTER: HANYA YANG DISETUJUI (HURUF BESAR/KECIL SAMA SAJA)
          AND w.status_verifikasi ILIKE 'disetujui'
        `;

        if (search) {
          query += ` AND w.nama_lengkap ILIKE $2`;
          params.push(`%${search}%`); 
        }

        query += " ORDER BY w.nama_lengkap ASC";
      } else {
        return res.status(403).json({ message: "Akses ditolak." });
      }
    }

    // Eksekusi Query
    const result = await pool.query(query, params);

    res.json({
      success: true,
      role: rwCheck.rows.length > 0 ? 'RW' : 'RT',
      data: result.rows
    });

  } catch (err) {
    console.error("Search Error:", err.message);
    res.status(500).json({ message: "Server Error saat mencari data" });
  }
};

/* ============================================================
   🔔 NOTIFIKASI UNTUK RW (Daftar RT Baru)
============================================================ */
export const getNotificationsRW = async (req, res) => {
  try {
    const userId = req.user.id_pengguna;

    // 1. Cari ID RW dari user yang login
    const rwCheck = await pool.query("SELECT id_rw FROM wilayah_rw WHERE id_pengguna = $1", [userId]);
    
    if (rwCheck.rows.length === 0) {
      return res.status(404).json({ message: "Data RW tidak ditemukan" });
    }
    const idRw = rwCheck.rows[0].id_rw;

    // 2. Ambil data RT yang terhubung ke RW ini
    // Diurutkan berdasarkan waktu pembuatan akun (id_pengguna DESC / created_at)
    const query = `
      SELECT 
        u.username AS nama_ketua,
        rt.kode_rt,
        u.created_at
      FROM wilayah_rt rt
      JOIN pengguna u ON rt.id_pengguna = u.id_pengguna
      WHERE rt.id_rw = $1
      ORDER BY u.created_at DESC
    `;
    
    const result = await pool.query(query, [idRw]);

    res.json({
      success: true,
      data: result.rows
    });

  } catch (err) {
    console.error("Notif Error:", err.message);
    res.status(500).json({ message: "Gagal mengambil notifikasi" });
  }
};
/* ============================================================
   ✅ VERIFIKASI AKUN RT (RW ACC RT) - VERSI STABIL
============================================================ */
export const verifikasiAkun = async (req, res) => {
  const { id } = req.params; 

  try {
    // KITA TEMBAK LANGSUNG STATUSNYA JADI '2' (AKTIF)
    // Asumsi: Di tabel pengguna kolomnya 'status_verifikasi_id' (Integer)
    // Jika ternyata error kolom tidak ada, ganti jadi 'status_verifikasi' dan nilainya 'disetujui'
    
    const updateQuery = `
      UPDATE pengguna 
      SET status_verifikasi_id = 2  -- Langsung set angka 2 (Aktif)
      WHERE id_pengguna = $1
      RETURNING id_pengguna, email, status_verifikasi_id
    `;

    const result = await pool.query(updateQuery, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "User RT tidak ditemukan" });
    }

    res.json({
      success: true,
      message: "Akun RT berhasil diverifikasi!",
      data: result.rows[0]
    });

  } catch (err) {
    console.error("Verifikasi RT Error:", err.message);
    
    // Cek jika errornya karena nama kolom salah
    if (err.message.includes('column "status_verifikasi_id" of relation "pengguna" does not exist')) {
        return res.status(500).json({ message: "Error DB: Kolom status_verifikasi_id tidak ada di tabel pengguna." });
    }
    
    res.status(500).json({ message: "Gagal memverifikasi akun RT" });
  }
};
/* ============================================================
   ✅ VERIFIKASI WARGA (RT ACC Warga) - FIX KEY NAME
============================================================ */
export const verifikasiWarga = async (req, res) => {
  try {
    const { id_warga } = req.params; 
    
    // PERBAIKAN DI SINI:
    // Gunakan 'status' agar sesuai dengan yang dikirim Frontend Flutter
    const { status } = req.body; 

    const updateQuery = `
      UPDATE warga 
      SET status_verifikasi = $1 
      WHERE id_warga = $2 
      RETURNING *
    `;

    // Pastikan variabel yang dimasukkan adalah 'status'
    const result = await pool.query(updateQuery, [status, id_warga]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Data warga tidak ditemukan" });
    }

    res.json({
      success: true,
      message: "Status warga berhasil diperbarui",
      data: result.rows[0]
    });

  } catch (err) {
    console.error("Verifikasi Warga Error:", err.message);
    res.status(500).json({ message: "Gagal memverifikasi warga" });
  }
};

/* ============================================================
   📝 AJUKAN PERUBAHAN DATA (Oleh Warga)
============================================================ */
export const ajukanPerubahan = async (req, res) => {
  try {
    const userId = req.user.id_pengguna;
    const { keterangan } = req.body; // User mengetik apa yang mau diubah

    // 1. Cari ID Warga berdasarkan User Login
    const wargaCheck = await pool.query("SELECT id_warga FROM warga WHERE pengguna_id = $1", [userId]);
    if (wargaCheck.rows.length === 0) return res.status(404).json({ message: "Data warga belum terhubung." });
    
    const idWarga = wargaCheck.rows[0].id_warga;

    // 2. Simpan ke Tabel Pengajuan
    await pool.query(
      "INSERT INTO pengajuan_perubahan (id_warga, keterangan) VALUES ($1, $2)",
      [idWarga, keterangan]
    );

    res.json({ success: true, message: "Pengajuan berhasil dikirim. Tunggu verifikasi RT." });

  } catch (err) {
    console.error("Ajukan Error:", err.message);
    res.status(500).json({ message: "Gagal mengirim pengajuan" });
  }
};

/* ============================================================
   📜 LIHAT RIWAYAT PENGAJUAN (Oleh Warga)
============================================================ */
export const getRiwayatSaya = async (req, res) => {
  try {
    const userId = req.user.id_pengguna;
    
    const query = `
      SELECT p.*, w.nama_lengkap 
      FROM pengajuan_perubahan p
      JOIN warga w ON p.id_warga = w.id_warga
      WHERE w.pengguna_id = $1
      ORDER BY p.created_at DESC
    `;

    const result = await pool.query(query, [userId]);

    res.json({ success: true, data: result.rows });

  } catch (err) {
    console.error("Riwayat Error:", err.message);
    res.status(500).json({ message: "Gagal mengambil riwayat" });
  }
};

// =================================================================
// ✅ FUNGSI BARU: Get Data Diri (Agar form tidak kosong saat dibuka)
// =================================================================
export const getDataDiri = async (req, res) => {
  try {
    const userId = req.user.id_pengguna;

    // 1. Coba cari data lengkap di tabel WARGA
    const qWarga = "SELECT * FROM warga WHERE pengguna_id = $1";
    const resultWarga = await pool.query(qWarga, [userId]);

    // Jika sudah pernah isi data warga, kirim datanya
    if (resultWarga.rows.length > 0) {
      return res.status(200).json(resultWarga.rows[0]);
    }

    // 2. [AUTO-FILL] Jika tabel warga KOSONG (User baru),
    // Ambil data dasar dari tabel PENGGUNA untuk mengisi form awal
    const qUser = "SELECT username, email FROM pengguna WHERE id_pengguna = $1";
    const resultUser = await pool.query(qUser, [userId]);

    if (resultUser.rows.length > 0) {
      const basicData = resultUser.rows[0];
      // Kita kirim format yang mirip dengan tabel warga
      // Supaya frontend bisa langsung menampilkannya
      return res.status(200).json({
        nama_lengkap: basicData.username, // Auto-isi nama dengan username dulu
        // Kamu bisa tambahkan field lain jika ada di tabel pengguna
        nik: "",
        pekerjaan: "",
        status_verifikasi: "belum_isi" // Penanda buat frontend
      });
    }

    // Jika benar-benar tidak ada data
    return res.status(200).json(null);

  } catch (err) {
    console.error("Error getDataDiri:", err);
    res.status(500).json({ message: "Gagal mengambil data diri" });
  }
};

// =================================================================
// ✅ FUNGSI UPDATE: Simpan Data Diri (Warga update sendiri)
// =================================================================
export const updateDataDiri = async (req, res) => {
  try {
    const userId = req.user.id_pengguna; // ID dari Token
    
    const { 
        nik, nama_lengkap, tempat_lahir, tanggal_lahir, jenis_kelamin, 
        agama, pekerjaan, status_perkawinan, golongan_darah, kewarganegaraan 
    } = req.body;

    // 1. Cek apakah data warga sudah ada untuk user ini?
    // FIX: Pakai 'pengguna_id'
    const checkQuery = "SELECT * FROM warga WHERE pengguna_id = $1"; 
    const checkResult = await pool.query(checkQuery, [userId]);

    if (checkResult.rows.length === 0) {
      return res.status(404).json({ message: "Data warga belum terhubung dengan akun ini. Hubungi RT." });
    }

    // 2. Lakukan Update
    // FIX: WHERE pengguna_id = $11
    const updateQuery = `
      UPDATE warga SET
        nik = COALESCE($1, nik),
        nama_lengkap = COALESCE($2, nama_lengkap),
        tempat_lahir = COALESCE($3, tempat_lahir),
        tanggal_lahir = COALESCE($4, tanggal_lahir),
        jenis_kelamin = COALESCE($5, jenis_kelamin),
        agama = COALESCE($6, agama),
        pekerjaan = COALESCE($7, pekerjaan),
        status_perkawinan = COALESCE($8, status_perkawinan),
        golongan_darah = COALESCE($9, golongan_darah),
        kewarganegaraan = COALESCE($10, kewarganegaraan)
      WHERE pengguna_id = $11  
      RETURNING *;
    `;

    const values = [
        nik, nama_lengkap, tempat_lahir, tanggal_lahir, 
        jenis_kelamin, agama, pekerjaan, status_perkawinan, 
        golongan_darah, kewarganegaraan, 
        userId 
    ];

    const result = await pool.query(updateQuery, values);

    res.status(200).json({ 
        message: "Data berhasil diperbarui", 
        data: result.rows[0] 
    });

  } catch (error) {
    console.error("Error updateDataDiri:", error);
    res.status(500).json({ message: "Terjadi kesalahan server" });
  }
};

/* ============================================================
   🔔 LIHAT DAFTAR PENGAJUAN PERUBAHAN (KHUSUS RT) - FIX ALAMAT
   ============================================================ */
export const getDaftarPengajuanRT = async (req, res) => {
  try {
    const userId = req.user.id_pengguna; 

    // 1. CEK: User ini RT nomor berapa?
    const cekRT = await pool.query(
        "SELECT id_rt FROM wilayah_rt WHERE id_pengguna = $1", 
        [userId]
    );

    if (cekRT.rows.length === 0) {
        return res.status(403).json({ message: "Akses ditolak. Anda bukan Pengurus RT." });
    }

    const rtId = cekRT.rows[0].id_rt; 

    // 2. AMBIL DATA PENGAJUAN (Status Pending)
    // FIX: Tambahkan JOIN ke wilayah_rt agar 'alamat_rt' bisa diambil
    const query = `
        SELECT 
            p.id AS id_pengajuan,
            p.keterangan,
            p.status,
            p.created_at,
            w.nama_lengkap,
            w.nik,
            rt.alamat_rt   -- Ambil alamat dari tabel RT (rt), bukan warga (w)
        FROM pengajuan_perubahan p
        JOIN warga w ON p.id_warga = w.id_warga
        JOIN wilayah_rt rt ON w.id_rt = rt.id_rt  -- <--- JOIN PENTING INI
        WHERE w.id_rt = $1          
        AND p.status = 'pending'    
        ORDER BY p.created_at DESC
    `;

    const result = await pool.query(query, [rtId]);

    console.log(`[NOTIF RT] Ditemukan ${result.rows.length} pengajuan.`);
    
    res.json({
        success: true,
        data: result.rows
    });

  } catch (err) {
    console.error("Error getDaftarPengajuanRT:", err.message);
    res.status(500).json({ message: "Server Error saat mengambil notifikasi" });
  }
};