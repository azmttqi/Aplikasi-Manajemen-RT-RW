-- ===== Roles =====
CREATE TABLE IF NOT EXISTS roles (
  id_role SERIAL PRIMARY KEY,
  nama_role VARCHAR(50) NOT NULL UNIQUE
);

-- pakai nama role yang sama dengan di authController.js
INSERT INTO roles (nama_role)
VALUES ('RW'), ('RT'), ('Warga')
ON CONFLICT (nama_role) DO NOTHING;

-- ===== Wilayah RW =====
CREATE TABLE IF NOT EXISTS wilayah_rw (
  id_rw SERIAL PRIMARY KEY,
  nama_rw VARCHAR(100) NOT NULL,
  kode_rw VARCHAR(10) UNIQUE,
  id_pengguna INTEGER
);

-- ===== Wilayah RT =====
CREATE TABLE IF NOT EXISTS wilayah_rt (
  id_rt SERIAL PRIMARY KEY,
  id_rw INTEGER NOT NULL REFERENCES wilayah_rw(id_rw) ON DELETE CASCADE,
  kode_rt VARCHAR(10) NOT NULL,
  id_pengguna INTEGER
);

-- ===== Warga =====
CREATE TABLE IF NOT EXISTS warga (
  id_warga SERIAL PRIMARY KEY,
  nama_lengkap VARCHAR(100) NOT NULL,
  nik VARCHAR(20) NOT NULL UNIQUE,
  no_kk VARCHAR(20),
  id_rt INTEGER REFERENCES wilayah_rt(id_rt) ON DELETE SET NULL,
  status_verifikasi VARCHAR(20) DEFAULT 'pending'
);

-- ===== Pengguna (Auth) =====
CREATE TABLE IF NOT EXISTS pengguna (
  id_pengguna SERIAL PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  username VARCHAR(100) UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  id_role INTEGER NOT NULL REFERENCES roles(id_role) ON DELETE RESTRICT,
  id_warga INTEGER REFERENCES warga(id_warga) ON DELETE SET NULL
);

-- ===== Index Tambahan =====
CREATE INDEX IF NOT EXISTS idx_warga_nik ON warga (nik);
CREATE INDEX IF NOT EXISTS idx_pengguna_email ON pengguna (email);

-- ===== Seed Wilayah =====
INSERT INTO wilayah_rw (nama_rw, kode_rw)
VALUES ('RW 01', 'RW001')
ON CONFLICT (kode_rw) DO NOTHING;

INSERT INTO wilayah_rt (id_rw, kode_rt)
VALUES 
  (1, 'RT001'),
  (1, 'RT002')
ON CONFLICT DO NOTHING;

-- ===== Seed Warga Contoh (opsional) =====
INSERT INTO warga (nama_lengkap, nik, no_kk, id_rt, status_verifikasi)
VALUES
('Warga Contoh 1', '3271010101010001', '3271010101010002', 1, 'disetujui'),
('Warga Contoh 2', '3271010101010003', '3271010101010004', 1, 'disetujui'),
('Warga Contoh 3', '3271010101010005', '3271010101010006', 2, 'disetujui')
ON CONFLICT DO NOTHING;

-- ===== Seed Pengguna Contoh =====
-- password_hash di bawah ini adalah hash bcrypt untuk "123456"
-- pastikan ini sesuai dengan authController (bcrypt.compare)

INSERT INTO pengguna (email, username, password_hash, id_role)
VALUES
(
  'rw001@mail.com',
  'rw001',
  '$2b$10$4j2v0jnPD.T/A2ZrAwTAwOni.qZkkga9B9NDptEm6cCkMaKqBG5CG',
  (SELECT id_role FROM roles WHERE nama_role = 'RW')
),
(
  'rt001@mail.com',
  'rt001',  
  '$2b$10$4j2v0jnPD.T/A2ZrAwTAwOni.qZkkga9B9NDptEm6cCkMaKqBG5CG',
  (SELECT id_role FROM roles WHERE nama_role = 'RT')
)
ON CONFLICT (email) DO NOTHING;
