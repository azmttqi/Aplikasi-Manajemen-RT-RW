🏘️ Aplikasi Manajemen RT/RW (Lingkar Warga)

Lingkar Warga adalah platform manajemen administrasi lingkungan digital yang dirancang untuk mempermudah pendataan warga, sistem verifikasi akun, hingga pelaporan mandiri secara transparan. Proyek ini dikembangkan sebagai Project Kuliah 14 SKS di Fakultas Sains dan Teknologi, Universitas Tazkia.

👥 Tim Pengembang

Azmi Ittaqi Hammami – Project Manager, System Analyst & Backend Developer

Amanda Wijayanti – UI/UX Designer & Frontend Developer

Muhammad Nabil Thoriq – Test Engineer

🚀 Arsitektur Proyek

Aplikasi ini menggunakan pendekatan kontainerisasi (Docker) untuk memastikan lingkungan pengembangan dan produksi tetap konsisten:

project-manajemen-RT-RW/
│
├── backend/               # Server API (Node.js + Express)
│   ├── src/
│   │   ├── database/      # Skrip setup.js & seed.js
│   │   ├── controllers/   # Logika Auth & Manajemen
│   │   └── ...
│   ├── public/            # Hasil build Flutter Web (Compiled)
│   └── .env               # Konfigurasi rahasia (DILARANG PUSH KE GITHUB)
│
├── frontend_flutter/      # Source code aplikasi Flutter (Frontend)
│
├── docker-compose.yml     # Konfigurasi Layanan Docker (App & DB)
└── README.md              # Dokumentasi Utama


💻 Prasyarat Sistem

Sebelum menjalankan proyek di laptop baru, pastikan perangkat Anda telah terpasang:

Git: Untuk manajemen versi kode.

Docker Desktop: Wajib untuk menjalankan database PostgreSQL dan Backend secara instan.

Flutter SDK: (Opsional) Hanya jika Anda ingin mengembangkan atau melakukan build ulang UI.

⚙️ Panduan Menjalankan Proyek

1. Clone Repository

Buka terminal dan jalankan perintah berikut:

git clone [https://github.com/azmttqi/Aplikasi-Manajemen-RT-RW.git](https://github.com/azmttqi/Aplikasi-Manajemen-RT-RW.git)
cd Aplikasi-Manajemen-RT-RW


2. Konfigurasi Environment (.env)

Buat file baru bernama .env di dalam folder backend/. Isi dengan template berikut (Sesuaikan dengan kredensial Anda):

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

Jalankan perintah ini di folder utama proyek:

docker compose up -d --build


4. Inisialisasi Database (WAJIB)

Langkah ini sangat penting untuk membangun tabel agar backend bisa berjalan:

docker exec -it backend_rtrw node src/database/setup.js


🔄 Alur Pembaruan (Development Workflow)

Update Tampilan (UI)

Lakukan perubahan di folder frontend_flutter.

Jalankan flutter build web di laptop lokal.

Lakukan git push, lalu di server jalankan git pull.

Jalankan docker compose up -d --build untuk memuat tampilan baru.

Update Database

Reset Struktur: Jalankan kembali setup.js (Hati-hati: Data lama akan terhapus).

Tambah Kolom: Gunakan perintah ALTER TABLE melalui terminal PostgreSQL Docker agar data tetap aman.

🌐 Akses Aplikasi

Frontend: http://localhost:5001 atau via domain resmi https://rtrw.demo.tazkia.ac.id

Backend API: http://localhost:5000/api

🛡️ Catatan Keamanan

DILARANG mengunggah file .env asli ke publik/GitHub.

Selalu gunakan file .gitignore untuk mengecualikan folder node_modules dan file rahasia lainnya.

✨ Dibuat dengan semangat gotong royong oleh tim Manajemen RT/RW.