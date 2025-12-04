import express from "express";
import { getDashboardStats } from "../controllers/dashboardController.js";
import { verifyToken } from "../middleware/authMiddleware.js"; // <--- Import ini

const router = express.Router();

// Tambahkan verifyToken sebelum controller
router.get("/stats", verifyToken, getDashboardStats); 

export default router;