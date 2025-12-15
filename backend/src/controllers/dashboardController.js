import pool from "../config/db.js";

/* ============================================================
   📊 DASHBOARD UTAMA (RW & RT)
   - RW: Melihat Statistik Global Wilayah (Hanya dari RT Aktif)
   - RT: Melihat Statistik Wilayahnya Sendiri
============================================================ */
export const getDashboardStats = async (req, res) => {
  try {
    const userId = req.user.id_pengguna; 

    // ==================================================
    // 1. CEK APAKAH USER ADALAH RW?
    // ==================================================
    const rwCheck = await pool.query("SELECT id_rw FROM wilayah_rw WHERE id_pengguna = $1", [userId]);
    
    if (rwCheck.rows.length > 0) {
      const idRw = rwCheck.rows[0].id_rw;

      // --- LOGIKA RW (FILTER HANYA RT YANG SUDAH AKTIF/VERIFIED) ---
      
      // A. Hitung Total Warga (Warga Disetujui & RT Aktif)
      const wargaRes = await pool.query(
        `SELECT COUNT(w.id_warga) 
         FROM warga w
         JOIN wilayah_rt rt ON w.id_rt = rt.id_rt
         JOIN pengguna u_rt ON rt.id_pengguna = u_rt.id_pengguna -- Cek Status Akun RT
         WHERE rt.id_rw = $1 
           AND w.status_verifikasi = 'disetujui'
           AND u_rt.status_verifikasi_id = 2`,
        [idRw]
      );
      
      // B. Hitung Total RT (Hanya RT yang Aktif)
      const rtRes = await pool.query(
        `SELECT COUNT(rt.id_rt) 
         FROM wilayah_rt rt
         JOIN pengguna u_rt ON rt.id_pengguna = u_rt.id_pengguna
         WHERE rt.id_rw = $1 
           AND u_rt.status_verifikasi_id = 2`, 
         [idRw]
      );
      
      // C. Hitung Total KK (Dari RT Aktif)
      const kkRes = await pool.query(
        `SELECT COUNT(DISTINCT w.no_kk) FROM warga w
         JOIN wilayah_rt rt ON w.id_rt = rt.id_rt
         JOIN pengguna u_rt ON rt.id_pengguna = u_rt.id_pengguna
         WHERE rt.id_rw = $1 
           AND w.status_verifikasi = 'disetujui'
           AND u_rt.status_verifikasi_id = 2`, 
        [idRw]
      );

      // D. Hitung Gender (Dari RT Aktif)
      const genderRes = await pool.query(
        `SELECT 
           SUM(CASE WHEN w.jenis_kelamin = 'Laki-laki' THEN 1 ELSE 0 END) AS laki,
           SUM(CASE WHEN w.jenis_kelamin = 'Perempuan' THEN 1 ELSE 0 END) AS perempuan
         FROM warga w
         JOIN wilayah_rt rt ON w.id_rt = rt.id_rt
         JOIN pengguna u_rt ON rt.id_pengguna = u_rt.id_pengguna
         WHERE rt.id_rw = $1 
           AND w.status_verifikasi = 'disetujui'
           AND u_rt.status_verifikasi_id = 2`,
        [idRw]
      );

      return res.json({
        success: true,
        role: 'RW',
        data: {
          total_warga: parseInt(wargaRes.rows[0].count),
          total_rt: parseInt(rtRes.rows[0].count),
          total_kk: parseInt(kkRes.rows[0].count),
          gender: {
            laki: parseInt(genderRes.rows[0].laki || 0),
            perempuan: parseInt(genderRes.rows[0].perempuan || 0)
          }
        }
      });
    }

    // ==================================================
    // 2. CEK APAKAH USER ADALAH RT?
    // ==================================================
    const rtCheck = await pool.query("SELECT id_rt FROM wilayah_rt WHERE id_pengguna = $1", [userId]);

    if (rtCheck.rows.length > 0) {
      const idRt = rtCheck.rows[0].id_rt;

      // A. Hitung Total Warga RT
      const wargaRes = await pool.query(
        "SELECT COUNT(*) FROM warga WHERE id_rt = $1 AND status_verifikasi = 'disetujui'", 
        [idRt]
      );

      // B. Hitung Total KK RT
      const kkRes = await pool.query(
        "SELECT COUNT(DISTINCT no_kk) FROM warga WHERE id_rt = $1 AND status_verifikasi = 'disetujui'", 
        [idRt]
      );

      // C. Hitung Gender RT
      const genderRes = await pool.query(
        `SELECT 
           SUM(CASE WHEN jenis_kelamin = 'Laki-laki' THEN 1 ELSE 0 END) AS laki,
           SUM(CASE WHEN jenis_kelamin = 'Perempuan' THEN 1 ELSE 0 END) AS perempuan
         FROM warga 
         WHERE id_rt = $1 AND status_verifikasi = 'disetujui'`,
        [idRt]
      );

      return res.json({
        success: true,
        role: 'RT',
        data: {
          total_warga: parseInt(wargaRes.rows[0].count),
          total_rt: 1, 
          total_kk: parseInt(kkRes.rows[0].count),
          gender: {
            laki: parseInt(genderRes.rows[0].laki || 0),
            perempuan: parseInt(genderRes.rows[0].perempuan || 0)
          }
        }
      });
    }

    // Jika bukan RW dan bukan RT
    return res.status(404).json({ message: "Data wilayah tidak ditemukan untuk pengguna ini" });

  } catch (err) {
    console.error("Dashboard Error:", err.message);
    res.status(500).json({ message: "Gagal mengambil data dashboard" });
  }
};


/* ============================================================
   📋 LIST RT BESERTA JUMLAH WARGA (KHUSUS DASHBOARD RW)
   - Hanya menghitung warga dari RT yang sudah Aktif
============================================================ */
export const getWargaPerRt = async (req, res) => {
  try {
    const userId = req.user.id_pengguna;

    // 1. Pastikan yang request adalah RW
    const rwCheck = await pool.query("SELECT id_rw FROM wilayah_rw WHERE id_pengguna = $1", [userId]);
    
    if (rwCheck.rows.length === 0) {
      return res.status(403).json({ message: "Akses ditolak. Anda bukan RW." });
    }

    const idRw = rwCheck.rows[0].id_rw;

    // 2. Query Data Statistik per RT
    // CATATAN: 
    // - Kita JOIN ke tabel pengguna (u_rt)
    // - CASE WHEN u_rt.status_verifikasi_id = 2 THEN ...
    //   Artinya: Jika RT belum aktif, hitungan warganya dianggap 0.
    
    const query = `
      SELECT 
        rt.nomor_rt,
        rt.id_rt,
        COUNT(CASE WHEN u_rt.status_verifikasi_id = 2 THEN w.id_warga END) as total_warga,
        COUNT(DISTINCT CASE WHEN u_rt.status_verifikasi_id = 2 THEN w.no_kk END) as total_kk,
        SUM(CASE WHEN w.jenis_kelamin = 'Laki-laki' AND u_rt.status_verifikasi_id = 2 THEN 1 ELSE 0 END) as laki,
        SUM(CASE WHEN w.jenis_kelamin = 'Perempuan' AND u_rt.status_verifikasi_id = 2 THEN 1 ELSE 0 END) as perempuan
      FROM wilayah_rt rt
      JOIN pengguna u_rt ON rt.id_pengguna = u_rt.id_pengguna
      LEFT JOIN warga w ON rt.id_rt = w.id_rt AND w.status_verifikasi = 'disetujui'
      WHERE rt.id_rw = $1
      GROUP BY rt.id_rt, rt.nomor_rt
      ORDER BY rt.nomor_rt ASC
    `;

    const result = await pool.query(query, [idRw]);

    // Parsing data string (dari COUNT/SUM) menjadi integer
    const data = result.rows.map(row => ({
      id_rt: row.id_rt,
      nomor_rt: row.nomor_rt,
      total_warga: parseInt(row.total_warga || 0),
      total_kk: parseInt(row.total_kk || 0),
      gender: {
        laki: parseInt(row.laki || 0),
        perempuan: parseInt(row.perempuan || 0)
      }
    }));

    res.json({
      success: true,
      data: data
    });

  } catch (err) {
    console.error("Error Per RT:", err.message);
    res.status(500).json({ message: "Gagal mengambil statistik per RT" });
  }
};