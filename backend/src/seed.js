import pool from './config/db.js';
import bcrypt from 'bcrypt';

const seedDatabase = async () => {
  const client = await pool.connect();

  try {
    console.log("🌱 Mulai Seeding Database...");
    await client.query('BEGIN'); // Mulai Transaksi

    // 1. BERSIHKAN DATA LAMA
    console.log("🧹 Membersihkan tabel lama...");
    await client.query('TRUNCATE TABLE pengajuan_perubahan, warga, wilayah_rt, wilayah_rw, pengguna, status_verifikasi, warna, roles RESTART IDENTITY CASCADE');

    // 2. INPUT ROLES MASTER
    console.log("📥 Insert Roles...");
    await client.query(`
      INSERT INTO roles (id_role, nama_role) VALUES 
      (1, 'RW'), (2, 'RT'), (3, 'Warga')
      ON CONFLICT DO NOTHING
    `);

    // 3A. INPUT WARNA
    console.log("📥 Insert Warna...");
    await client.query(`
      INSERT INTO warna (id, nama) VALUES 
      (1, 'Kuning'), (2, 'Hijau'), (3, 'Merah')
      ON CONFLICT DO NOTHING
    `);

    // 3B. INPUT STATUS VERIFIKASI
    console.log("📥 Insert Status Verifikasi...");
    await client.query(`
      INSERT INTO status_verifikasi (id, nama, warna_id) VALUES 
      (1, 'Pending', 1),
      (2, 'Disetujui', 2),
      (3, 'Ditolak', 3)
      ON CONFLICT DO NOTHING
    `);

    // 4. SIAPKAN PASSWORD HASH
    const passwordHash = await bcrypt.hash('123456', 10);

    // ===========================================
    // 5. BUAT AKUN RW
    // ===========================================
    console.log("👤 Membuat Akun RW...");
    // FIX: Hapus nama_lengkap dari sini
    const rwUser = await client.query(`
      INSERT INTO pengguna (email, username, password_hash, id_role, status_verifikasi_id, created_at)
      VALUES ($1, $2, $3, 1, 2, NOW())
      RETURNING id_pengguna
    `, ['rw01@gmail.com', 'rw01', passwordHash]);
    
    const idRwUser = rwUser.rows[0].id_pengguna;

    const rwWilayah = await client.query(`
      INSERT INTO wilayah_rw (nama_rw, kode_rw, alamat_rw, id_pengguna)
      VALUES ('RW 001', 'RW-KODE-1', 'Jl. Mawar Pusat', $1)
      RETURNING id_rw
    `, [idRwUser]);
    
    const idRwWilayah = rwWilayah.rows[0].id_rw;

    // ===========================================
    // 6. BUAT AKUN RT
    // ===========================================
    console.log("👤 Membuat Akun RT...");
    // FIX: Hapus nama_lengkap dari sini
    const rtUser = await client.query(`
      INSERT INTO pengguna (email, username, password_hash, id_role, status_verifikasi_id, created_at)
      VALUES ($1, $2, $3, 2, 2, NOW())
      RETURNING id_pengguna
    `, ['rt05@gmail.com', 'rt05', passwordHash]);

    const idRtUser = rtUser.rows[0].id_pengguna;

    const rtWilayah = await client.query(`
      INSERT INTO wilayah_rt (kode_rt, nomor_rt, alamat_rt, id_rw, id_pengguna) 
      VALUES ('RT-KODE-005', '005', 'Jl. Melati No 5', $1, $2)
      RETURNING id_rt
    `, [idRwWilayah, idRtUser]);

    const idRtWilayah = rtWilayah.rows[0].id_rt;

    // ===========================================
    // 7. BUAT AKUN WARGA
    // ===========================================
    console.log("👥 Membuat Warga...");
    
    // Warga 1 (Sudah Aktif)
    // FIX: Hapus nama_lengkap dari tabel pengguna (tapi di tabel warga tetap ada)
    const warga1User = await client.query(`
      INSERT INTO pengguna (email, username, password_hash, id_role, status_verifikasi_id, created_at)
      VALUES ('udin@gmail.com', 'udin123', $1, 3, 2, NOW())
      RETURNING id_pengguna
    `, [passwordHash]);

    await client.query(`
      INSERT INTO warga (nama_lengkap, nik, no_kk, jenis_kelamin, id_rt, pengguna_id, status_verifikasi)
      VALUES ('Udin Sedunia', '3201000000000001', '3201KK00001', 'L', $1, $2, 'disetujui')
    `, [idRtWilayah, warga1User.rows[0].id_pengguna]);

    // Warga 2 (Masih Pending)
    const warga2User = await client.query(`
      INSERT INTO pengguna (email, username, password_hash, id_role, status_verifikasi_id, created_at)
      VALUES ('siti@gmail.com', 'siti123', $1, 3, 1, NOW())
      RETURNING id_pengguna
    `, [passwordHash]);

    await client.query(`
      INSERT INTO warga (nama_lengkap, nik, no_kk, jenis_kelamin, id_rt, pengguna_id, status_verifikasi)
      VALUES ('Siti Aminah', '3201000000000002', '3201KK00002', 'P', $1, $2, 'pending')
    `, [idRtWilayah, warga2User.rows[0].id_pengguna]);


    await client.query('COMMIT');
    console.log("✅ SEEDING SELESAI! Database siap digunakan.");
    process.exit(0);

  } catch (err) {
    await client.query('ROLLBACK');
    console.error("❌ SEEDING GAGAL:", err);
    process.exit(1);
  } finally {
    client.release();
  }
};

seedDatabase();