// src/routes/warga.js
import express from "express";
import {
    getDataDiri, updateDataDiri, 
    getDataList, addWarga, ajukanPerubahan, getRiwayatSaya, getNotifikasiWarga,
    getPendingWargaForRT, verifikasiWarga, updateWarga, deleteWarga, getDaftarPengajuanRT, verifikasiPengajuan, getRejectedWargaForRT,
    getStatistikWargaRT,
    getAllWargaByRW, getStatistikWargaByRW, getDashboardRW, getNotificationsRW, verifikasiAkun,
    getStatistikWargaRWDetail,
} from "../controllers/wargaController.js";
import { verifyToken } from "../middleware/authMiddleware.js";
import { ensureRoleRT, ensureRoleRW } from "../middleware/roleMiddleware.js";

const router = express.Router();

// =================================================================
// ✅ ROUTE ANTI-BENTROK (Gunakan 2 segmen kata)
// =================================================================

// 1. Ambil Data (Ganti jadi /pribadi/saya)
// Route "/:id" tidak akan bisa memakan route ini karena ada 2 garis miring
router.get("/pribadi/saya", verifyToken, getDataDiri);

// 2. Simpan Data (Ganti jadi /pribadi/update)
router.put("/update-data", verifyToken, updateDataDiri);


// =================================================================
// 🟡 ROUTE UMUM
// =================================================================
router.get("/", verifyToken, getDataList);
router.post("/", verifyToken, addWarga);
router.post("/pengajuan", verifyToken, ajukanPerubahan);
router.get("/pengajuan/riwayat", verifyToken, getRiwayatSaya);
router.get("/notifikasi", verifyToken, getNotifikasiWarga);

// =================================================================
// 🟠 KHUSUS RT
// =================================================================
router.get("/statistik/rt", verifyToken, ensureRoleRT, getStatistikWargaRT);
router.get("/pending", verifyToken, ensureRoleRT, getPendingWargaForRT);
router.put("/verify/:id_warga", verifyToken, ensureRoleRT, verifikasiWarga);
router.get("/pengajuan/rt", verifyToken, getDaftarPengajuanRT);
router.put("/pengajuan/verify/:id", verifyToken, ensureRoleRT, verifikasiPengajuan);
router.get("/rejected", verifyToken, ensureRoleRT, getRejectedWargaForRT);

// =================================================================
// ⛔ ROUTE PARAMETER ID (Sekarang aman di bawah sini)
// =================================================================
router.put("/:id", verifyToken, ensureRoleRT, updateWarga);
router.delete("/:id", verifyToken, ensureRoleRT, deleteWarga);

// =================================================================
// 🔵 KHUSUS RW
// =================================================================
router.get("/rw/statistik/detail", verifyToken, ensureRoleRW, getStatistikWargaRWDetail);
router.get("/rw/statistik/rincian", verifyToken, ensureRoleRW, getStatistikWargaRWDetail);
router.get("/rw/warga", verifyToken, ensureRoleRW, getAllWargaByRW);
router.get("/rw/statistik", verifyToken, ensureRoleRW, getStatistikWargaByRW);
router.get("/rw/dashboard", verifyToken, ensureRoleRW, getDashboardRW);
router.get("/rw/notifications", verifyToken, ensureRoleRW, getNotificationsRW);
router.put("/rw/verify/:id", verifyToken, ensureRoleRW, verifikasiAkun);

export default router;