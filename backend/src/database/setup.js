import pool from "../config/db.js";

const setupDatabase = async () => {
  const client = await pool.connect();
  try {
    console.log("🔄 Mulai mereset database sesuai kodingan backend...");

    // 1. HAPUS TABEL LAMA (Urutan penting biar gak error foreign key)
    await client.query("DROP TABLE IF EXISTS warga CASCADE");
    await client.query("DROP TABLE IF EXISTS wilayah_rt CASCADE");
    await client.query("DROP TABLE IF EXISTS wilayah_rw CASCADE");
    await client.query("DROP TABLE IF EXISTS pengguna CASCADE");
    await client.query("DROP TABLE IF EXISTS roles CASCADE");
    await client.query("DROP TABLE IF EXISTS status_verifikasi CASCADE");

    // 2. BUAT TABEL MASTER (Roles & Status)
    await client.query(`
      CREATE TABLE roles (
        id_role SERIAL PRIMARY KEY,
        nama_role VARCHAR(50) NOT NULL UNIQUE
      );
    `);

    await client.query(`
      CREATE TABLE status_verifikasi (
        id SERIAL PRIMARY KEY,
        nama VARCHAR(50) NOT NULL UNIQUE
      );
    `);

    // 3. BUAT TABEL PENGGUNA (Sesuai kodingan authController: password_hash)
    await client.query(`
      CREATE TABLE pengguna (
        id_pengguna SERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL, -- Kodingan kamu pakai ini, bukan 'password'
        id_role INTEGER REFERENCES roles(id_role),
        status_verifikasi_id INTEGER REFERENCES status_verifikasi(id),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 4. BUAT TABEL WILAYAH (RW & RT)
    await client.query(`
      CREATE TABLE wilayah_rw (
        id_rw SERIAL PRIMARY KEY,
        nama_rw VARCHAR(50),
        kode_rw VARCHAR(50) UNIQUE NOT NULL,
        alamat_rw TEXT,
        id_pengguna INTEGER REFERENCES pengguna(id_pengguna) -- Relasi ke akun Pak RW
      );
    `);

    await client.query(`
      CREATE TABLE wilayah_rt (
        id_rt SERIAL PRIMARY KEY,
        nomor_rt VARCHAR(10),
        kode_rt VARCHAR(50) UNIQUE NOT NULL,
        alamat_rt TEXT,
        id_rw INTEGER REFERENCES wilayah_rw(id_rw),
        id_pengguna INTEGER REFERENCES pengguna(id_pengguna) -- Relasi ke akun Pak RT
      );
    `);

    // 5. BUAT TABEL WARGA (LENGKAP dengan kolom updateDataWarga)
    await client.query(`
      CREATE TABLE warga (
        id_warga SERIAL PRIMARY KEY,
        nama_lengkap VARCHAR(100),
        nik VARCHAR(20) UNIQUE,
        no_kk VARCHAR(20),
        tanggal_lahir DATE,
        id_rt INTEGER REFERENCES wilayah_rt(id_rt),
        pengguna_id INTEGER REFERENCES pengguna(id_pengguna),
        
        -- Kolom Status
        status_verifikasi VARCHAR(20) DEFAULT 'pending',

        -- Kolom Tambahan (dari fungsi updateDataWarga)
        tempat_lahir VARCHAR(100),
        jenis_kelamin VARCHAR(20),
        agama VARCHAR(20),
        pekerjaan VARCHAR(50),
        status_perkawinan VARCHAR(20),
        golongan_darah VARCHAR(5)
        kewarganegaraan VARCHAR(50) DEFAULT 'WNI',
      );
    `);

    // 6. ISI DATA MASTER (Seeding)
    // Masukkan Role (Penting untuk Register)
    await client.query(`
      INSERT INTO roles (id_role, nama_role) VALUES 
      (1, 'RW'), (2, 'RT'), (3, 'Warga') 
      ON CONFLICT DO NOTHING;
    `);

    // Masukkan Status (Penting untuk Register)
    await client.query(`
      INSERT INTO status_verifikasi (id, nama) VALUES 
      (1, 'Diajukan'), (2, 'Diverifikasi'), (3, 'Ditolak') 
      ON CONFLICT DO NOTHING;
    `);

    // Tambahkan ini di dalam query setup database kamu
    await client.query(`
      CREATE TABLE IF NOT EXISTS pengajuan_perubahan (
        id SERIAL PRIMARY KEY,
        id_warga INTEGER NOT NULL,
        keterangan TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    const createPengajuanTable = `
    CREATE TABLE IF NOT EXISTS pengajuan_perubahan (
        id SERIAL PRIMARY KEY,
        id_warga INTEGER NOT NULL REFERENCES warga(id_warga) ON DELETE CASCADE, -- Tambahkan Foreign Key biar aman
        keterangan TEXT NOT NULL,
        status VARCHAR(20) DEFAULT 'pending', -- Ini yang tadi bikin error notifikasi
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Ini yang tadi bikin error riwayat
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
`;
      await client.query(createPengajuanTable);

    console.log("✅ Database berhasil dibangun ulang & sinkron dengan kodingan!");
  } catch (err) {
    console.error("❌ Gagal setup database:", err);
  } finally {
    client.release();
    // Tutup pool agar script berhenti
    pool.end(); 
  }
};

setupDatabase();