import express from 'express';
import { seedArmor } from "../../seeds/seed-dev.js";
const router = express.Router();

router.post("/armor", async (req, res) => {
  const result = await seedArmor();
  res.json({ message: result});
});

export default router;