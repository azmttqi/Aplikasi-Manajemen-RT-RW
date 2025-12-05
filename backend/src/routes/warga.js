import express from "express";
import {
    // Controller Lama
    addWarga,
    updateWarga,
    deleteWarga,
    getPendingWargaForRT,
    verifikasiWarga,
    getAllWargaByRW,
    getStatistikWargaByRW,
    getDashboardRW,
    
    // Controller Baru (PENTING!)
    getDataList,
    getNotificationsRW,
    verifikasiAkun 
} from "../controllers/wargaController.js";

import { verifyToken } from "../middleware/authMiddleware.js";
import { ensureRoleRT, ensureRoleRW } from "../middleware/roleMiddleware.js";

const router = express.Router();

// =================================================================
// 🟢 ROUTES UTAMA
// =================================================================

// 1. GET "/" -> Ini yang dipakai halaman Pencarian Akun
// Menggunakan getDataList agar otomatis mendeteksi role (RW lihat RT, RT lihat Warga)
router.get("/", verifyToken, getDataList);

// 2. POST "/" -> Tambah Warga
router.post("/", verifyToken, addWarga);


// =================================================================
// 🟠 ROUTES KHUSUS RT
// =================================================================
router.get("/pending", verifyToken, ensureRoleRT, getPendingWargaForRT);
router.put("/verifikasi", verifyToken, ensureRoleRT, verifikasiWarga);

// Update & Delete Warga (Biasanya RT)
router.put("/:id", verifyToken, updateWarga); // Menggunakan :id (bukan nik) jika query by ID
router.delete("/:id", verifyToken, deleteWarga);


// =================================================================
// 🔵 ROUTES KHUSUS RW
// =================================================================
router.get("/rw/warga", verifyToken, ensureRoleRW, getAllWargaByRW);
router.get("/rw/statistik", verifyToken, ensureRoleRW, getStatistikWargaByRW);
router.get("/rw/dashboard", verifyToken, ensureRoleRW, getDashboardRW);

// Route Notifikasi
router.get("/rw/notifications", verifyToken, ensureRoleRW, getNotificationsRW);
// Route Verifikasi (PUT karena mengupdate data)
router.put("/verify/:id", verifyToken, ensureRoleRW, verifikasiAkun);
export default router;