// 1. IMPORTS
import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import path from 'path'; // Tambahkan ini
import { fileURLToPath } from 'url'; // Tambahkan ini untuk ESM

// Import Koneksi Database
import pool from './config/db.js';

// Import Routes
import authRoutes from './routes/auth.js';
import wargaRoutes from './routes/warga.js';
import dashboardRoutes from "./routes/dashboard.js";
import { verifyToken } from './middleware/authMiddleware.js';

// Konfigurasi __dirname untuk ESM
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 2. CONFIGURATION & MIDDLEWARE
dotenv.config();
const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// --- TAMBAHKAN INI: Menyajikan File Flutter ---
// Kita arahkan ke folder '../public' karena app.js ada di dalam folder 'src'
app.use(express.static(path.join(__dirname, '../public')));

// 3. ROUTING (API)
app.use('/api/auth', authRoutes);
app.use('/api/warga', wargaRoutes);
app.use('/api/dashboard', dashboardRoutes);

app.get('/api/protected', verifyToken, (req, res) => {
  res.json({ message: "✅ Token Valid!", user_info: req.user });
});

// --- UBAH INI: Route Utama ---
// Agar ketika buka localhost:5000, yang muncul adalah Flutter, bukan tulisan teks
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../public', 'index.html'));
});

// 4. SERVER LISTENER
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server & UI running on: http://localhost:${PORT}`);
});