import express from "express";
import {
    // --- Controller Umum & Warga ---
    addWarga,
    updateWarga,
    deleteWarga,
    getDataList, // Smart Controller (Bisa buat RT & RW)
    ajukanPerubahan,
    getRiwayatSaya,

    // --- Controller Khusus RT ---
    getPendingWargaForRT,
    verifikasiWarga, // ✅ Fungsi Verifikasi Warga (Penting!)

    // --- Controller Khusus RW ---
    getAllWargaByRW,
    getStatistikWargaByRW,
    getDashboardRW,
    getNotificationsRW,
    verifikasiAkun, // Fungsi RW verifikasi RT
} from "../controllers/wargaController.js";

import { verifyToken } from "../middleware/authMiddleware.js";
import { ensureRoleRT, ensureRoleRW } from "../middleware/roleMiddleware.js";

const router = express.Router();

// =================================================================
// 🟢 ROUTES UMUM (Pencarian & Tambah)
// =================================================================

// 1. GET "/" -> Halaman Pencarian Data Warga
// (Otomatis: Jika RT login -> lihat Warga, Jika RW login -> lihat RT)
router.get("/", verifyToken, getDataList);

// 2. POST "/" -> Tambah Data Warga Baru
router.post("/", verifyToken, addWarga);

router.post("/pengajuan", verifyToken, ajukanPerubahan);
router.get("/pengajuan/riwayat", verifyToken, getRiwayatSaya);

// =================================================================
// 🟠 ROUTES KHUSUS RT (Mengelola Warga)
// =================================================================

// Get Warga Pending (List Verifikasi)
router.get("/pending", verifyToken, ensureRoleRT, getPendingWargaForRT);

// ✅ FIX: Route Verifikasi Warga (Tombol Disetujui/Tolak)
// Sebelumnya Anda lupa memasukkan 'verifikasiWarga' di sini
router.put("/verify/:id_warga", verifyToken, ensureRoleRT, verifikasiWarga);

// Update & Delete Warga (Edit Data)
router.put("/:id", verifyToken, ensureRoleRT, updateWarga);
router.delete("/:id", verifyToken, ensureRoleRT, deleteWarga);


// =================================================================
// 🔵 ROUTES KHUSUS RW (Mengelola RT & Dashboard)
// =================================================================

// Data Warga se-RW
router.get("/rw/warga", verifyToken, ensureRoleRW, getAllWargaByRW);

// Statistik & Dashboard RW
router.get("/rw/statistik", verifyToken, ensureRoleRW, getStatistikWargaByRW);
router.get("/rw/dashboard", verifyToken, ensureRoleRW, getDashboardRW);

// Notifikasi RW
router.get("/rw/notifications", verifyToken, ensureRoleRW, getNotificationsRW);

// Verifikasi Akun RT (Oleh RW)
// Kita bedakan URL-nya sedikit agar tidak bentrok dengan verifikasi warga
router.put("/rw/verify/:id", verifyToken, ensureRoleRW, verifikasiAkun);

export default router;