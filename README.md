
---

# 🏘️ Aplikasi Manajemen RT/RW (Lingkar Warga)

**Lingkar Warga** adalah platform manajemen administrasi lingkungan digital yang dirancang untuk mempermudah pendataan warga, sistem verifikasi akun, hingga pelaporan mandiri secara transparan. Proyek ini dikembangkan sebagai **Project Kuliah 14 SKS** di Fakultas Sains dan Teknologi, Universitas Tazkia.

Proyek ini merupakan sistem manajemen data warga berbasis **digital**, yang terdiri dari:

* **Backend (API Server)** → Node.js + Express + PostgreSQL
* **Frontend (Mobile & Web)** → Flutter
* **Containerization** → Docker & Docker Compose

---

## 👥 Tim Pengembang

| Nama | Peran |
| --- | --- |
| **Azmi Ittaqi Hammami** | Project Manager, System Analyst & Backend Developer |
| **Amanda Wijayanti** | UI/UX Designer & Frontend Developer |
| **Muhammad Nabil Thoriq** | Test Engineer |

---

## 🚀 Arsitektur Proyek

Aplikasi ini menggunakan pendekatan kontainerisasi untuk memastikan lingkungan pengembangan dan produksi tetap konsisten:

```plaintext
project-manajemen-RT-RW/
│
├── backend/                # Server API (Node.js + Express)
│   ├── src/
│   │   ├── database/       # Skrip setup.js & seed.js
│   │   ├── controllers/    # Logika Auth & Manajemen
│   │   └── ...
│   ├── public/             # Hasil build Flutter Web (Compiled)
│   └── .env                # Konfigurasi rahasia (DILARANG PUSH)
│
├── frontend_flutter/       # Source code aplikasi Flutter
│
├── docker-compose.yml      # Konfigurasi Layanan Docker (App & DB)
└── README.md               # Dokumentasi Utama

```

---

## 💻 Prasyarat Sistem

Sebelum menjalankan proyek, pastikan perangkat Anda telah terpasang:

* **Git**: Untuk manajemen versi kode.
* **Docker Desktop**: Wajib untuk menjalankan database PostgreSQL dan Backend secara instan.
* **Flutter SDK**: (Opsional) Hanya jika ingin melakukan build ulang UI atau pengembangan frontend.

---

## ⚙️ Panduan Menjalankan Proyek

### 🔹 1. Clone Repository

```bash
git clone https://github.com/azmttqi/Aplikasi-Manajemen-RT-RW.git
cd Aplikasi-Manajemen-RT-RW

```

### 🔹 2. Konfigurasi Environment (.env)

Buat file baru bernama `.env` di dalam folder `backend/`. Isi dengan template berikut:

```ini
# DATABASE CONFIG
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password_aman_anda
POSTGRES_DB=db_rtrw
DB_HOST=db_rtrw
DB_PORT=5432

# SERVER CONFIG
PORT=5000
JWT_SECRET=kode_rahasia_jwt_anda

# EMAIL CONFIG (GOOGLE SMTP)
MAIL_USERNAME=manajemenrtrw@gmail.com
MAIL_PASSWORD=isi_dengan_google_app_password
MAIL_HOST=smtp.googlemail.com
MAIL_PORT=587

```

### 🔹 3. Build dan Jalankan Docker

Jalankan perintah ini di folder utama proyek untuk membangun kontainer:

```bash
docker compose up -d --build

```

### 🔹 4. Inisialisasi Database (WAJIB)

Bangun struktur tabel agar backend dapat terhubung ke database dengan benar:

```bash
docker exec -it backend_rtrw node src/database/setup.js

```

> **Tip:** Gunakan `seed.js` jika ingin memasukkan data dummy akun RW/RT awal.

---

## 🔄 Alur Pembaruan (Development Workflow)

### **Update Tampilan (UI)**

1. Lakukan perubahan di folder `frontend_flutter`.
2. Jalankan `flutter build web` di laptop Anda.
3. Lakukan `git push`, lalu di server jalankan `git pull`.
4. Jalankan `docker compose up -d --build` untuk memuat tampilan baru.

### **Update Database**

* **Reset Data**: Jalankan kembali `setup.js` (Catatan: Semua data lama akan terhapus).
* **Ubah Kolom**: Gunakan perintah `ALTER TABLE` melalui terminal PostgreSQL Docker agar data tetap aman.

---

## 🌐 Akses Aplikasi

* **Frontend**: [http://localhost:5001](https://www.google.com/search?q=http://localhost:5001) atau via domain resmi [rtrw.demo.tazkia.ac.id](https://rtrw.demo.tazkia.ac.id)
* **Backend API**: [http://localhost:5000/api](https://www.google.com/search?q=http://localhost:5000/api)

---

## 🛡️ Catatan Keamanan

* **DILARANG** mengunggah file `.env` asli ke publik/GitHub.
* Selalu gunakan file `.gitignore` untuk mengeclualikan `node_modules` dan file rahasia lainnya.
* **Privacy Error**: Jika muncul peringatan keamanan di browser, pastikan SSL Certbot sudah terpasang di server Nginx.

---

✨ Dibuat dengan semangat gotong royong oleh tim Manajemen RT/RW.

---
