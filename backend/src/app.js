// src/app.js

// --- SEMUA IMPORTS HARUS DI ATAS ---

// 1. Ubah require('express') menjadi import express
import express from 'express'; 
import dotenv from "dotenv";
import cors from "cors";
import pool from "./config/db.js";
import authRoutes from "./routes/auth.js";
import { verifyToken } from "./middleware/authMiddleware.js";
import wargaRoutes from "./routes/warga.js";

// --- START APP LOGIC ---

dotenv.config();
const app = express();
app.use(cors());
app.use(express.json());

// Routing
app.use("/api/auth", authRoutes);
app.use("/api/warga", wargaRoutes);

app.get("/api/protected", verifyToken, (req, res) => {
  res.json({
    message: "Akses diterima ✅",
    user: req.user
  });
});


app.get("/", (req, res) => {
    res.send("Server & Database OK ✅");
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
console.log(`🚀 Server running on port ${PORT}`);
});