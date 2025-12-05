// src/controllers/wargaController.js
import pool from "../config/db.js";

/* ============================================================
   ➕ TAMBAH WARGA
============================================================ */
export const addWarga = async (req, res) => {
  const { nama_lengkap, nik, no_kk, id_rt } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO warga (nama_lengkap, nik, no_kk, id_rt, status_verifikasi)
       VALUES ($1, $2, $3, $4, 'pending')
       RETURNING *`,
      [nama_lengkap, nik, no_kk, id_rt]
    );
    res.status(201).json({
      message: "✅ Data warga berhasil ditambahkan",
      data: result.rows[0],
    });
  } catch (err) {
    console.error("❌ Gagal menambahkan warga:", err.message);
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
   ❌ HAPUS WARGA (berdasarkan NIK)
============================================================ */
export const deleteWarga = async (req, res) => {
  const { nik } = req.params;

  try {
    const result = await pool.query("DELETE FROM warga WHERE nik = $1 RETURNING *", [nik]);
    if (result.rowCount === 0)
      return res.status(404).json({ message: "Warga tidak ditemukan" });

    res.json({ message: "Data warga berhasil dihapus", data: result.rows[0] });
  } catch (err) {
    console.error("❌ Gagal menghapus warga:", err.message);
    res.status(500).json({ message: "Gagal menghapus data warga", error: err.message });
  }
};

/* ============================================================
   👀 WARGA PENDING UNTUK RT LOGIN
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
      `SELECT nama_lengkap, nik, no_kk, id_rt, status_verifikasi
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

// /* ============================================================
//    ✅ VERIFIKASI WARGA OLEH RT
// ============================================================ */
// export const verifikasiWarga = async (req, res) => {
//   try {
//     const userId = req.user.id_pengguna;
//     const { nik, status_verifikasi } = req.body;

//     if (!nik || !status_verifikasi)
//       return res.status(400).json({ message: "NIK dan status_verifikasi wajib diisi" });

//     const wilayahRes = await pool.query(
//       "SELECT id_rt FROM wilayah_rt WHERE id_pengguna = $1",
//       [userId]
//     );
//     if (wilayahRes.rowCount === 0)
//       return res.status(400).json({ message: "RT belum memiliki wilayah" });

//     const id_rt = wilayahRes.rows[0].id_rt;

//     const updateRes = await pool.query(
//       `UPDATE warga
//        SET status_verifikasi = $1
//        WHERE nik = $2 AND id_rt = $3
//        RETURNING *`,
//       [status_verifikasi.toLowerCase(), nik, id_rt]
//     );

//     if (updateRes.rowCount === 0)
//       return res.status(404).json({ message: "Warga tidak ditemukan di RT ini" });

//     res.status(200).json({
//       message: `Warga dengan NIK ${nik} berhasil diverifikasi (${status_verifikasi})`,
//       data: updateRes.rows[0],
//     });
//   } catch (err) {
//     console.error("❌ Gagal verifikasi warga:", err.message);
//     res.status(500).json({ message: "Gagal memverifikasi warga", error: err.message });
//   }
// };

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
   🔍 GET DATA LIST (FIX SEARCH)
============================================================ */
export const getDataList = async (req, res) => {
  try {
    const userId = req.user.id_pengguna; 
    const { search } = req.query; // Ambil kata kunci search
    
    let query = "";
    let params = [];

    // 1. Cek Apakah RW?
    const rwCheck = await pool.query("SELECT id_rw FROM wilayah_rw WHERE id_pengguna = $1", [userId]);
    
    if (rwCheck.rows.length > 0) {
      const idRw = rwCheck.rows[0].id_rw;
      params.push(idRw); // params[0] adalah idRw ($1)

      query = `
        SELECT 
            rt.id_rt, 
            rt.kode_rt AS nomor_rt,       
            rt.alamat_rt,
            u.username AS nama_ketua_rt, 
            u.email,
            u.id_pengguna,
            u.status_verifikasi_id,
            (SELECT COUNT(*) FROM warga w WHERE w.id_rt = rt.id_rt) AS jumlah_warga,
            (SELECT COUNT(DISTINCT no_kk) FROM warga w WHERE w.id_rt = rt.id_rt) AS jumlah_kk
        FROM wilayah_rt rt
        LEFT JOIN pengguna u ON rt.id_pengguna = u.id_pengguna
        WHERE rt.id_rw = $1
      `;

      // --- LOGIKA SEARCH UNTUK RW ---
      if (search) {
        // Cari berdasarkan Nama Ketua ATAU Kode RT
        query += ` AND (u.username ILIKE $2 OR rt.kode_rt ILIKE $2)`;
        params.push(`%${search}%`); // params[1] adalah search keyword ($2)
      }
      
      query += " ORDER BY rt.kode_rt ASC"; 
    } 
    
    // 2. Cek Apakah RT?
    else {
      const rtCheck = await pool.query("SELECT id_rt FROM wilayah_rt WHERE id_pengguna = $1", [userId]);
      
      if (rtCheck.rows.length > 0) {
        const idRt = rtCheck.rows[0].id_rt;
        params.push(idRt); // params[0] adalah idRt ($1)
        
        query = `
          SELECT 
            w.id_warga, 
            w.nama_lengkap, 
            w.nik, 
            w.no_kk, 
            w.status_verifikasi 
          FROM warga w
          WHERE w.id_rt = $1
        `;

        // --- LOGIKA SEARCH UNTUK RT ---
        if (search) {
          // Cari berdasarkan Nama Warga
          query += ` AND w.nama_lengkap ILIKE $2`;
          params.push(`%${search}%`); // params[1] adalah search keyword ($2)
        }

        query += " ORDER BY w.id_warga DESC";
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
    console.error("Search Error:", err.message); // Cek terminal backend jika error
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
   ✅ VERIFIKASI AKUN (Ubah Status jadi Disetujui)
============================================================ */
export const verifikasiAkun = async (req, res) => {
  const { id } = req.params; // ID User yang mau diverifikasi (dikirim dari URL)

  try {
    // 1. Update status_verifikasi_id di tabel pengguna
    // Asumsi: ID 2 = 'Disetujui' (Sesuai seed data Anda sebelumnya)
    // Atau kita pakai subquery biar aman
    const updateQuery = `
      UPDATE pengguna 
      SET status_verifikasi_id = (SELECT id FROM status_verifikasi WHERE nama = 'Disetujui' LIMIT 1)
      WHERE id_pengguna = $1
      RETURNING id_pengguna, email, status_verifikasi_id
    `;

    const result = await pool.query(updateQuery, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "User tidak ditemukan" });
    }

    res.json({
      success: true,
      message: "Akun berhasil diverifikasi!",
      data: result.rows[0]
    });

  } catch (err) {
    console.error("Verifikasi Error:", err.message);
    res.status(500).json({ message: "Gagal memverifikasi akun" });
  }
};
/* ============================================================
   ✅ UPDATE STATUS WARGA (FINAL FIX: status_verifikasi)
============================================================ */
export const verifikasiWarga = async (req, res) => {
  try {
    const { id_warga } = req.params; 
    const { status_id } = req.body;  // Frontend kirim: 2 (Aktif), 0 (Tolak)

    // FIX: Gunakan nama kolom yang benar: 'status_verifikasi'
    const updateQuery = `
      UPDATE warga 
      SET status_verifikasi = $1 
      WHERE id_warga = $2 
      RETURNING *
    `;

    const result = await pool.query(updateQuery, [status_id, id_warga]);

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