import express from "express";
import { registerRW, registerRT, registerWarga, login, getMe } from "../controllers/authController.js";
import { verifyToken } from '../middleware/authMiddleware.js';
const router = express.Router();

router.post("/register-rw", registerRW);
router.post("/register-rt", registerRT);
router.post("/register-warga", registerWarga);
router.post("/login", login);
router.get('/me', verifyToken, getMe);

export default router;
