// =========================================
// 1. IMPORTS (SEMUA HARUS DI ATAS)
// =========================================
import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';

// Import Koneksi Database (Agar tereksekusi)
import pool from './config/db.js';

// Import Routes
import authRoutes from './routes/auth.js';
import wargaRoutes from './routes/warga.js'; // Pastikan file ini ada, jika belum ada bisa dikomentari dulu

// Import Middleware
import { verifyToken } from './middleware/authMiddleware.js';

// =========================================
// 2. CONFIGURATION & MIDDLEWARE
// =========================================
dotenv.config(); // Load environment variables
const app = express();

// A. CORS (PENTING: Agar Flutter Web/Browser tidak diblokir)
app.use(cors());

// B. Body Parser (Agar bisa baca req.body format JSON)
app.use(express.json());

// =========================================
// 3. ROUTING (DAFTAR ALAMAT API)
// =========================================

// Route Autentikasi (Register & Login)
// Akses: http://localhost:5000/api/auth/register-rw, dll
app.use('/api/auth', authRoutes);

// Route Data Warga (Contoh: Dashboard RW)
// Akses: http://localhost:5000/api/warga/...
// Jika file warga.js belum siap, baris ini bisa dikomentari dulu:
app.use('/api/warga', wargaRoutes);

// Route Test Token (Hanya bisa diakses jika punya token login)
app.get('/api/protected', verifyToken, (req, res) => {
  res.json({
    message: "✅ Token Valid! Akses diterima.",
    user_info: req.user // Data user dari token
  });
});

// Route Cek Server (Health Check)
// Akses: http://localhost:5000/
app.get('/', (req, res) => {
  res.send('Server & Database OK ✅');
});

// =========================================
// 4. SERVER LISTENER
// =========================================
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`==========================================`);
  console.log(`🚀 Server running on: http://localhost:${PORT}`);
  console.log(`==========================================`);
});