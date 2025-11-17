-- PostgreSQL Schema Conversion (Final and Corrected Version)

-- ==============================================================================
-- 0. Drop Tabel yang Ada (Dilakukan secara Aman dengan CASCADE)
-- ==============================================================================

DROP TABLE IF EXISTS "biodata_warga_pengajuan" CASCADE;
DROP TABLE IF EXISTS "warga" CASCADE;
DROP TABLE IF EXISTS "wilayah_rt" CASCADE;
DROP TABLE IF EXISTS "wilayah_rw" CASCADE;
DROP TABLE IF EXISTS "pengguna" CASCADE;
DROP TABLE IF EXISTS "roles" CASCADE;
DROP TABLE IF EXISTS "status_verifikasi" CASCADE;
DROP TABLE IF EXISTS "warna" CASCADE;
DROP TABLE IF EXISTS "jenis_pengguna" CASCADE;


-- ==============================================================================
-- 1. Tabel Master Pendukung
-- ==============================================================================

-- ===== Warna (Dari Dump MySQL) =====
CREATE TABLE IF NOT EXISTS warna (
  id SERIAL PRIMARY KEY,
  nama VARCHAR(255) NOT NULL UNIQUE -- Tambahkan UNIQUE untuk seeding yang aman
);

-- ===== Status Verifikasi (Dari Dump MySQL) =====
CREATE TABLE IF NOT EXISTS status_verifikasi (
  id SERIAL PRIMARY KEY,
  nama VARCHAR(255) NOT NULL UNIQUE, -- Tambahkan UNIQUE untuk seeding yang aman
  warna_id INTEGER NOT NULL REFERENCES warna(id) ON DELETE RESTRICT
);

-- ===== Roles (Dari Skema Kedua) =====
CREATE TABLE IF NOT EXISTS roles (
  id_role SERIAL PRIMARY KEY,
  nama_role VARCHAR(50) NOT NULL UNIQUE
);


-- ==============================================================================
-- 2. Tabel Wilayah (Diadopsi dan Ditingkatkan)
-- ==============================================================================

-- ===== Wilayah RW (Menggantikan biodata_rw) =====
CREATE TABLE IF NOT EXISTS wilayah_rw (
  id_rw SERIAL PRIMARY KEY,
  nama_rw VARCHAR(100) DEFAULT NULL,
  kode_rw VARCHAR(10) UNIQUE, -- Digunakan sebagai target ON CONFLICT
  alamat_rw VARCHAR(255) DEFAULT NULL,
  id_pengguna INTEGER -- FK ke pengguna, ditambahkan belakangan
);

-- ===== Wilayah RT (Menggantikan biodata_rt) =====
CREATE TABLE IF NOT EXISTS wilayah_rt (
  id_rt SERIAL PRIMARY KEY,
  id_rw INTEGER NOT NULL REFERENCES wilayah_rw(id_rw) ON DELETE CASCADE,
  kode_rt VARCHAR(10) NOT NULL,
  alamat_rt VARCHAR(255) DEFAULT NULL,
  id_pengguna INTEGER, -- FK ke pengguna, ditambahkan belakangan
  
  -- Solusi: Batasan unik gabungan (Composite Unique Constraint) untuk RT/RW
  UNIQUE (id_rw, kode_rt) 
);


-- ==============================================================================
-- 3. Tabel Pengguna (Penggabungan Kedua Skema)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS pengguna (
  id_pengguna SERIAL PRIMARY KEY,
  -- Kolom otentikasi
  email VARCHAR(255) NOT NULL UNIQUE, -- Digunakan sebagai target ON CONFLICT
  username VARCHAR(100) UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  
  -- Kolom relasi
  id_role INTEGER NOT NULL REFERENCES roles(id_role) ON DELETE RESTRICT,
  status_verifikasi_id INTEGER NOT NULL REFERENCES status_verifikasi(id) ON DELETE RESTRICT,
  id_warga INTEGER, -- FK ke warga, ditambahkan belakangan

  -- Kolom tambahan dari Dump MySQL
  is_hapus BOOLEAN NOT NULL DEFAULT FALSE,
  reset_token VARCHAR(255) DEFAULT NULL,
  is_superuser BOOLEAN NOT NULL DEFAULT FALSE,
  verifikasi_email BOOLEAN DEFAULT NULL,
  kode_verifikasi_email VARCHAR(255) DEFAULT NULL
);


-- ==============================================================================
-- 4. Tabel Warga dan Pengajuan
-- ==============================================================================

-- ===== Warga (Menggantikan biodata_warga) =====
CREATE TABLE IF NOT EXISTS warga (
  id_warga SERIAL PRIMARY KEY,
  nama_lengkap VARCHAR(255) DEFAULT NULL,
  nik VARCHAR(255) DEFAULT NULL UNIQUE, -- Digunakan sebagai target ON CONFLICT
  no_kk VARCHAR(255) DEFAULT NULL,
  tanggal_lahir DATE DEFAULT NULL,
  
  -- Relasi dan Status
  id_rt INTEGER REFERENCES wilayah_rt(id_rt) ON DELETE SET NULL,
  status_verifikasi VARCHAR(20) DEFAULT 'pending',
  pengguna_id INTEGER REFERENCES pengguna(id_pengguna) ON DELETE RESTRICT
);

-- ===== Biodata Warga Pengajuan (Dipertahankan dari Dump MySQL) =====
CREATE TABLE IF NOT EXISTS biodata_warga_pengajuan (
  id SERIAL PRIMARY KEY,
  pengguna_id INTEGER NOT NULL REFERENCES pengguna(id_pengguna) ON DELETE RESTRICT,
  nama_lengkap VARCHAR(255) DEFAULT NULL,
  nik VARCHAR(255) DEFAULT NULL,
  nomor_kk VARCHAR(255) DEFAULT NULL,
  tanggal_lahir DATE DEFAULT NULL,
  status VARCHAR(100) DEFAULT NULL,
  alasan VARCHAR(100) DEFAULT NULL,
  url_dokumen_pendukung VARCHAR(100) DEFAULT NULL
);


-- ==============================================================================
-- 5. Menambahkan Foreign Key yang Tertunda
-- ==============================================================================

-- Memperbarui relasi wilayah ke pengguna (Ketua RT/RW)
ALTER TABLE wilayah_rw
ADD CONSTRAINT fk_wilayah_rw_pengguna
FOREIGN KEY (id_pengguna)
REFERENCES pengguna(id_pengguna) ON DELETE SET NULL;

ALTER TABLE wilayah_rt
ADD CONSTRAINT fk_wilayah_rt_pengguna
FOREIGN KEY (id_pengguna)
REFERENCES pengguna(id_pengguna) ON DELETE SET NULL;

-- Memperbarui relasi pengguna ke warga (Profil Warga)
ALTER TABLE pengguna
ADD CONSTRAINT fk_pengguna_warga
FOREIGN KEY (id_warga)
REFERENCES warga(id_warga) ON DELETE SET NULL;


-- ==============================================================================
-- 6. Index Tambahan
-- ==============================================================================

CREATE INDEX IF NOT EXISTS idx_warga_nik ON warga (nik);
CREATE INDEX IF NOT EXISTS idx_pengguna_email ON pengguna (email);


-- ==============================================================================
-- 7. Seed Data (Dengan ON CONFLICT yang Ditargetkan)
-- ==============================================================================

-- ===== Seed Roles =====
INSERT INTO roles (nama_role)
VALUES ('RW'), ('RT'), ('Warga')
ON CONFLICT (nama_role) DO NOTHING;

-- ===== Seed Warna dan Status Verifikasi =====
INSERT INTO warna (nama) VALUES
('Merah'), ('Kuning'), ('Hijau'), ('Biru')
ON CONFLICT (nama) DO NOTHING;

INSERT INTO status_verifikasi (nama, warna_id) VALUES
('Diajukan', (SELECT id FROM warna WHERE nama = 'Kuning')),
('Disetujui', (SELECT id FROM warna WHERE nama = 'Hijau')),
('Ditolak', (SELECT id FROM warna WHERE nama = 'Merah'))
ON CONFLICT (nama) DO NOTHING;

-- ===== Seed Wilayah =====
INSERT INTO wilayah_rw (nama_rw, kode_rw)
VALUES ('RW 01', 'RW001')
ON CONFLICT (kode_rw) DO NOTHING; -- Target kode_rw (UNIQUE)

INSERT INTO wilayah_rt (id_rw, kode_rt)
VALUES
  (1, 'RT001'),
  (1, 'RT002')
ON CONFLICT (id_rw, kode_rt) DO NOTHING; -- Target (id_rw, kode_rt) (UNIQUE)

-- ===== Seed Warga Contoh =====
INSERT INTO warga (nama_lengkap, nik, no_kk, id_rt, status_verifikasi)
VALUES
('Warga Contoh 1', '3271010101010001', '3271010101010002', 1, 'disetujui'),
('Warga Contoh 2', '3271010101010003', '3271010101010004', 1, 'disetujui'),
('Warga Contoh 3', '3271010101010005', '3271010101010006', 2, 'disetujui')
ON CONFLICT (nik) DO NOTHING; -- Target nik (UNIQUE)

-- ===== Seed Pengguna Contoh =====
-- password_hash di bawah ini adalah hash bcrypt untuk "123456"

INSERT INTO pengguna (email, username, password_hash, id_role, status_verifikasi_id)
VALUES
(
  'rw001@mail.com',
  'rw001',
  '$2b$10$4j2v0jnPD.T/A2ZrAwTAwOni.qZkkga9B9NDptEm6cCkMaKqBG5CG',
  (SELECT id_role FROM roles WHERE nama_role = 'RW'),
  (SELECT id FROM status_verifikasi WHERE nama = 'Disetujui')
),
(
  'rt001@mail.com',
  'rt001',
  '$2b$10$4j2v0jnPD.T/A2ZrAwTAwOni.qZkkga9B9NDptEm6cCkMaKqBG5CG',
  (SELECT id_role FROM roles WHERE nama_role = 'RT'),
  (SELECT id FROM status_verifikasi WHERE nama = 'Disetujui')
)
ON CONFLICT (email) DO NOTHING; -- Target email (UNIQUE)