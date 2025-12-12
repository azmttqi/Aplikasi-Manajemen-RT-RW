import express from "express";
import { registerRW, registerRT, registerWarga, login, getMe, updateProfile, getWargaDetailById, updateDataWarga  } from "../controllers/authController.js";
import { verifyToken, cekRole } from '../middleware/authMiddleware.js'; 
const router = express.Router();

router.post("/register-rw", registerRW);
router.post("/register-rt", registerRT);
router.post("/register-warga", registerWarga);
router.post("/login", login);
router.get('/me', verifyToken, getMe);
router.put("/update", verifyToken, updateProfile);
router.put('/warga/update-data', verifyToken, cekRole(['RT', 'Warga']), updateDataWarga);
router.get('/rt/warga-detail/:id_warga', verifyToken, getWargaDetailById);
export default router;
