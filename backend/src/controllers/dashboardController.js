import pool from "../config/db.js";

export const getDashboardStats = async (req, res) => {
  try {
    const userId = req.user.id_pengguna; 

    // ==================================================
    // 1. CEK APAKAH USER ADALAH RW?
    // ==================================================
    const rwCheck = await pool.query("SELECT id_rw FROM wilayah_rw WHERE id_pengguna = $1", [userId]);
    
    if (rwCheck.rows.length > 0) {
      const idRw = rwCheck.rows[0].id_rw;

      // Hitung Total Warga (Semua RT di bawah RW ini)
      const wargaRes = await pool.query(
        `SELECT COUNT(w.id_warga) 
         FROM warga w
         JOIN wilayah_rt rt ON w.id_rt = rt.id_rt
         WHERE rt.id_rw = $1`, 
        [idRw]
      );
      
      // Hitung Total RT
      const rtRes = await pool.query(
        "SELECT COUNT(*) FROM wilayah_rt WHERE id_rw = $1", [idRw]
      );
      
      // Hitung Total KK
      const kkRes = await pool.query(
        `SELECT COUNT(DISTINCT w.no_kk) FROM warga w
         JOIN wilayah_rt rt ON w.id_rt = rt.id_rt
         WHERE rt.id_rw = $1`, [idRw]
      );

      return res.json({
        success: true,
        role: 'RW',
        data: {
          total_warga: wargaRes.rows[0].count,
          total_rt: rtRes.rows[0].count,
          total_kk: kkRes.rows[0].count,
        }
      });
    }

    // ==================================================
    // 2. CEK APAKAH USER ADALAH RT?
    // ==================================================
    const rtCheck = await pool.query("SELECT id_rt FROM wilayah_rt WHERE id_pengguna = $1", [userId]);

    if (rtCheck.rows.length > 0) {
      const idRt = rtCheck.rows[0].id_rt;

      // Hitung Total Warga
      const wargaRes = await pool.query(
        "SELECT COUNT(*) FROM warga WHERE id_rt = $1", [idRt]
      );

      // Hitung Total KK
      const kkRes = await pool.query(
        "SELECT COUNT(DISTINCT no_kk) FROM warga WHERE id_rt = $1", [idRt]
      );

      return res.json({
        success: true,
        role: 'RT',
        data: {
          total_warga: wargaRes.rows[0].count,
          total_rt: 1, // RT cuma 1 (dirinya sendiri)
          total_kk: kkRes.rows[0].count,
        }
      });
    }

    return res.status(404).json({ message: "Data wilayah tidak ditemukan" });

  } catch (err) {
    console.error("Dashboard Error:", err.message);
    res.status(500).json({ message: "Gagal mengambil data dashboard" });
  }
};