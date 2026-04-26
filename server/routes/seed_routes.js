import express from 'express';
import { seedArmor, seedWeapon, seedTag, seedGear, seedCurio, seedArtifact, seedTalent, seedPath, seedAdvance } from "../../seeds/seed-dev.js";

const router = express.Router();

router.post("/all", async (req, res) => {
  const result = await seedArmor();
  const result2 = await seedWeapon();
  const result3 = await seedGear();
  const result4 = await seedTag();
  const result5 = await seedCurio();
  const result6 = await seedArtifact();
  const result7 = await seedPath();
  const result8 = await seedTalent();
  // const result9 = await seedAdvance();
  res.json({ message: result});
});

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

router.post("/path", async (req, res) => {
  const result = await seedPath();
  res.json({ message: result});
});

router.post("/talent", async (req, res) => {
  const result = await seedTalent();
  res.json({ message: result});
});

router.post("/advance", async (req, res) => {
  const result = await seedAdvance();
  res.json({ message: result});
});

export default router;