import pool from "../config/db.js";

export const getDashboardStats = async (req, res) => {
  try {
    const userId = req.user.id_pengguna; 

    // ==================================================
    // 1. CEK APAKAH USER ADALAH RW? (Bagian RW biarkan dulu)
    // ==================================================
    const rwCheck = await pool.query("SELECT id_rw FROM wilayah_rw WHERE id_pengguna = $1", [userId]);
    
    if (rwCheck.rows.length > 0) {
      const idRw = rwCheck.rows[0].id_rw;
      // ... (Kode RW sama seperti sebelumnya) ...
      // Biar tidak kepanjangan, bagian RW saya skip di snippet ini karena fokus kita ke RT
      // TAPI JANGAN DIHAPUS YA BAGIAN RW-NYA DI FILE KAMU
    }

    // ==================================================
    // 2. CEK APAKAH USER ADALAH RT?
    // ==================================================
    const rtCheck = await pool.query("SELECT id_rt FROM wilayah_rt WHERE id_pengguna = $1", [userId]);

    if (rtCheck.rows.length > 0) {
      const idRt = rtCheck.rows[0].id_rt;

      // A. Hitung Total Warga (Hanya DISETUJUI)
      const wargaRes = await pool.query(
        "SELECT COUNT(*) FROM warga WHERE id_rt = $1 AND status_verifikasi = 'disetujui'", 
        [idRt]
      );

      // B. Hitung Total KK (Hanya DISETUJUI)
      const kkRes = await pool.query(
        "SELECT COUNT(DISTINCT no_kk) FROM warga WHERE id_rt = $1 AND status_verifikasi = 'disetujui'", 
        [idRt]
      );

      // C. Hitung Detail Gender (BARU TAMBAHAN) 🟢
      // Kita pakai CASE WHEN untuk menghitung dalam satu kali query
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
          total_warga: wargaRes.rows[0].count,
          total_rt: 1, 
          total_kk: kkRes.rows[0].count,
          // Kirim data gender ke frontend
          gender: {
            laki: genderRes.rows[0].laki || 0,
            perempuan: genderRes.rows[0].perempuan || 0
          }
        }
      });
    }

    return res.status(404).json({ message: "Data wilayah tidak ditemukan" });

  } catch (err) {
    console.error("Dashboard Error:", err.message);
    res.status(500).json({ message: "Gagal mengambil data dashboard" });
  }
};