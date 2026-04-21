import express from 'express';
import { seedArmor, seedWeapon, seedTag, seedGear, seedCurio, seedArtifact } from "../../seeds/seed-dev.js";

const router = express.Router();

router.post("/armor", async (req, res) => {
  const result = await seedArmor();
  res.json({ message: result});
});

router.post("/weapon", async (req, res) => {
  const result = await seedWeapon();
  res.json({ message: result});
});

router.post("/gear", async (req, res) => {
  const result = await seedGear();
  res.json({ message: result});
});

router.post("/tag", async (req, res) => {
  const result = await seedTag();
  res.json({ message: result});
});

router.post("/curio", async (req, res) => {
  const result = await seedCurio();
  res.json({ message: result});
});

router.post("/artifact", async (req, res) => {
  const result = await seedArtifact();
  res.json({ message: result});
});

export default router;