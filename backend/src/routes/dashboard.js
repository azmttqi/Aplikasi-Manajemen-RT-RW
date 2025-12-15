import express from "express";
import { verifyToken } from "../middleware/authMiddleware.js";

// PERHATIKAN BARIS INI: 
// Pastikan getWargaPerRt ada di dalam kurung kurawal { }
import { 
  getDashboardStats, 
  getWargaPerRt      // <--- JANGAN LUPA INI
} from "../controllers/dashboardController.js";

const router = express.Router();

// Jalur 1: Statistik Utama (Jumlah Warga, KK, dll)
router.get("/stats", verifyToken, getDashboardStats);

// Jalur 2: Statistik Per RT (List RT untuk RW)
router.get("/stats/per-rt", verifyToken, getWargaPerRt);

export default router;