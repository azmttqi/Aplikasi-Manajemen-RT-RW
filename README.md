🏘️ Aplikasi Manajemen RT/RW (Lingkar Warga)
Lingkar Warga adalah platform manajemen administrasi lingkungan berbasis digital yang dirancang untuk mempermudah pendataan warga, sistem verifikasi akun, hingga pelaporan mandiri. Proyek ini merupakan bagian dari tugas kuliah 14 SKS di Sistem Informasi, STMIK Tazkia.

👥 Tim Pengembang
Azmi Ittaqi Hammami – Project Manager, System Analyst & Backend Developer

Amanda Wijayanti – UI/UX Designer & Frontend Developer

Muhammad Nabil Thoriq – Test Engineer

🚀 Arsitektur Proyek
Aplikasi ini menggunakan pendekatan kontainerisasi untuk memastikan lingkungan pengembangan dan produksi tetap sama:

Plaintext
project-manajemen-RT-RW/
│
├── backend/               # Server API (Node.js + Express)
│   ├── src/
│   │   ├── database/      # Skrip setup.js & seed.js
│   │   ├── controllers/   # Logika Auth & Manajemen
│   │   └── ...
│   ├── public/            # Hasil build Flutter Web (Compiled)
│   └── .env               # Konfigurasi rahasia (DILARANG PUSH)
│
├── frontend_flutter/      # Source code aplikasi Flutter
│
├── docker-compose.yml     # Konfigurasi Layanan Docker
└── README.md              # Dokumentasi Utama
💻 Prasyarat Sistem
Sebelum menjalankan proyek, pastikan perangkat Anda telah terpasang:

Git: Untuk manajemen versi kode.

Docker Desktop: Wajib untuk menjalankan database PostgreSQL dan Backend secara instan.

Flutter SDK: (Opsional) Hanya jika Anda ingin melakukan build ulang UI atau pengembangan frontend.

⚙️ Panduan Menjalankan Proyek
1. Clone Repository
git clone https://github.com/azmttqi/Aplikasi-Manajemen-RT-RW.git
cd Aplikasi-Manajemen-RT-RW

2. Konfigurasi Environment (.env)
Buat file bernama .env di dalam folder backend/. Gunakan template di bawah ini:

Cuplikan kode
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

3. Build dan Jalankan Docker
Jalankan perintah ini di folder utama proyek untuk membangun kontainer:

docker compose up -d --build
4. Inisialisasi Database (WAJIB)
Anda harus membangun struktur tabel agar backend dapat terhubung ke database dengan benar:

docker exec -it backend_rtrw node src/database/setup.js
Gunakan seed.js jika ingin memasukkan data dummy akun RW/RT awal.

🔄 Alur Pembaruan (Development Workflow)
Update Tampilan (UI)
Lakukan perubahan di folder frontend_flutter.

Jalankan flutter build web di laptop Anda.

Lakukan git push, lalu di server jalankan git pull.

Lakukan docker compose up -d --build untuk memuat tampilan baru.

Update Database
Reset Data: Gunakan setup.js (Catatan: Semua data lama akan terhapus).

Ubah Kolom: Gunakan perintah ALTER TABLE melalui terminal PostgreSQL Docker agar data tetap aman.

🌐 Akses Aplikasi
Frontend: http://localhost:5001 (atau via domain resmi https://rtrw.demo.tazkia.ac.id).

Backend API: http://localhost:5000/api.

🛡️ Catatan Keamanan & Troubleshooting
Privacy Error: Jika muncul peringatan keamanan di browser, pastikan SSL Certbot sudah terpasang di server Nginx.

Failed to Fetch: Pastikan baseUrl di aplikasi Flutter mengarah ke domain resmi, bukan lagi ke localhost.

Data Persistence: Data database tersimpan di volume Docker db_data. Jangan menghapus volume ini kecuali ingin melakukan reset total.