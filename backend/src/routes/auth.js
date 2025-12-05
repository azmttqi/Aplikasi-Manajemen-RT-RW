import express from "express";
import { registerRW, registerRT, registerWarga, login, getMe, updateProfile } from "../controllers/authController.js";
import { verifyToken } from '../middleware/authMiddleware.js';  
const router = express.Router();

router.post("/register-rw", registerRW);
router.post("/register-rt", registerRT);
router.post("/register-warga", registerWarga);
router.post("/login", login);
router.get('/me', verifyToken, getMe);
router.put("/update", verifyToken, updateProfile);
export default router;
