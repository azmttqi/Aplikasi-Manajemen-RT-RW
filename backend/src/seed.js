// src/seed.js
import pool from './config/db.js';
import bcrypt from 'bcrypt';

const seedDatabase = async () => {
  const client = await pool.connect();

  try {
    console.log("🌱 Mulai Seeding Database...");
    await client.query('BEGIN'); // Mulai Transaksi

    // 1. BERSIHKAN DATA LAMA (Opsional: Biar tidak duplikat error)
    // Hati-hati: Ini akan menghapus data lama setiap kali dijalankan!
    console.log("🧹 Membersihkan tabel lama...");
    await client.query('TRUNCATE TABLE pengajuan_perubahan, warga, wilayah_rt, wilayah_rw, pengguna, status_verifikasi, roles RESTART IDENTITY CASCADE');

    // 2. INPUT ROLES MASTER
    console.log("📥 Insert Roles...");
    await client.query(`
      INSERT INTO roles (id_role, nama_role) VALUES 
      (1, 'RW'), (2, 'RT'), (3, 'Warga')
      ON CONFLICT DO NOTHING
    `);

    // 3. INPUT STATUS VERIFIKASI MASTER
    console.log("📥 Insert Status Verifikasi...");
    await client.query(`
      INSERT INTO status_verifikasi (id, nama) VALUES 
      (1, 'Pending'), (2, 'Disetujui'), (3, 'Ditolak')
      ON CONFLICT DO NOTHING
    `);

    // 4. SIAPKAN PASSWORD HASH (Semua user passwordnya '123456')
    const passwordHash = await bcrypt.hash('123456', 10);

    // ===========================================
    // 5. BUAT AKUN RW
    // ===========================================
    console.log("👤 Membuat Akun RW...");
    const rwUser = await client.query(`
      INSERT INTO pengguna (nama_lengkap, email, username, password_hash, id_role, status_verifikasi_id, created_at)
      VALUES ($1, $2, $3, $4, 1, 2, NOW()) -- Status 2 = Disetujui
      RETURNING id_pengguna
    `, ['Bapak RW 01', 'rw01@gmail.com', 'rw01', passwordHash]);
    
    const idRwUser = rwUser.rows[0].id_pengguna;

    // Buat Wilayah RW
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
    const rtUser = await client.query(`
      INSERT INTO pengguna (nama_lengkap, email, username, password_hash, id_role, status_verifikasi_id, created_at)
      VALUES ($1, $2, $3, $4, 2, 2, NOW())
      RETURNING id_pengguna
    `, ['Bapak RT 05', 'rt05@gmail.com', 'rt05', passwordHash]);

    const idRtUser = rtUser.rows[0].id_pengguna;

    // Buat Wilayah RT (Terhubung ke RW 001)
    const rtWilayah = await client.query(`
      INSERT INTO wilayah_rt (kode_rt, alamat_rt, id_rw, id_pengguna)
      VALUES ('005', 'Jl. Melati No 5', $1, $2)
      RETURNING id_rt
    `, [idRwWilayah, idRtUser]);

    const idRtWilayah = rtWilayah.rows[0].id_rt;

    // ===========================================
    // 7. BUAT AKUN WARGA (CONTOH 2 WARGA)
    // ===========================================
    console.log("👥 Membuat Warga...");
    
    // Warga 1 (Sudah Aktif)
    const warga1User = await client.query(`
      INSERT INTO pengguna (nama_lengkap, email, username, password_hash, id_role, status_verifikasi_id, created_at)
      VALUES ('Udin Sedunia', 'udin@gmail.com', 'udin123', $1, 3, 2, NOW())
      RETURNING id_pengguna
    `, [passwordHash]);

    await client.query(`
      INSERT INTO warga (nama_lengkap, nik, no_kk, jenis_kelamin, id_rt, pengguna_id, status_verifikasi)
      VALUES ('Udin Sedunia', '3201000000000001', '3201KK00001', 'L', $1, $2, 'disetujui')
    `, [idRtWilayah, warga1User.rows[0].id_pengguna]);

    // Warga 2 (Masih Pending - Buat Tes Verifikasi)
    const warga2User = await client.query(`
      INSERT INTO pengguna (nama_lengkap, email, username, password_hash, id_role, status_verifikasi_id, created_at)
      VALUES ('Siti Aminah', 'siti@gmail.com', 'siti123', $1, 3, 1, NOW()) -- Status 1 = Pending
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