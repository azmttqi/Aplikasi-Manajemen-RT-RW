import express from "express";
import { registerRW, registerRT, registerWarga, login, getMe, updateProfile, getWargaDetailById, updateDataWarga, forgotPassword, resetPasswordProcess, getResetPasswordPage } from "../controllers/authController.js";
import { verifyToken, cekRole } from '../middleware/authMiddleware.js'; 
const router = express.Router();

router.post("/register-rw", registerRW);
router.post("/register-rt", registerRT);
router.post("/register-warga", registerWarga);
router.post("/login", login);
router.post('/forgot-password', forgotPassword);
router.get('/me', verifyToken, getMe);
router.put("/update", verifyToken, updateProfile);
router.put('/warga/update-data', verifyToken, cekRole(['RT', 'Warga']), updateDataWarga);
router.get('/rt/warga-detail/:id_warga', verifyToken, getWargaDetailById);
// Route untuk menampilkan halaman HTML
router.get('/reset-password-page', getResetPasswordPage);
// Route untuk memproses form HTML
router.post('/reset-password-process', resetPasswordProcess);
export default router;
