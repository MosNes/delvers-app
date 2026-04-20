import express from 'express';
import { seedArmor, seedWeapon, seedTag } from "../../seeds/seed-dev.js";

const router = express.Router();

router.post("/armor", async (req, res) => {
  const result = await seedArmor();
  res.json({ message: result});
});

router.post("/weapon", async (req, res) => {
  const result = await seedWeapon();
  res.json({ message: result});
});

router.post("/tag", async (req, res) => {
  const result = await seedTag();
  res.json({ message: result});
});

export default router;