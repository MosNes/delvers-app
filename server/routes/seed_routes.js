import express from 'express';
import { seedArmor, seedWeapon, seedTag, seedGear, seedCurio, seedArtifact, seedTalent, seedPath } from "../../seeds/seed-dev.js";

// #region agent log
fetch('http://127.0.0.1:7404/ingest/2d4e9d71-11c8-44e4-9942-b525874d6801',{method:'POST',headers:{'Content-Type':'application/json','X-Debug-Session-Id':'6de2c2'},body:JSON.stringify({sessionId:'6de2c2',location:'seed_routes.js:after-imports',message:'seed_routes import bindings',data:{typeofSeedTalent:typeof seedTalent,typeofSeedArmor:typeof seedArmor,seedTalentName:typeof seedTalent!=='undefined'?String(seedTalent&&seedTalent.name):'TDZ_or_missing'},timestamp:Date.now(),hypothesisId:'H2'})}).catch(()=>{});
// #endregion

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
  // #region agent log
  fetch('http://127.0.0.1:7404/ingest/2d4e9d71-11c8-44e4-9942-b525874d6801',{method:'POST',headers:{'Content-Type':'application/json','X-Debug-Session-Id':'6de2c2'},body:JSON.stringify({sessionId:'6de2c2',location:'seed_routes.js:/talent-entry',message:'POST /talent handler entered',data:{typeofSeedTalent:typeof seedTalent},timestamp:Date.now(),hypothesisId:'H3'})}).catch(()=>{});
  // #endregion
  const result = await seedTalent();
  res.json({ message: result});
});

export default router;