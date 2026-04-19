import express from 'express';
const router = express.Router();

router.post("/armor", async (req, res) => {
  //pass in env to give seed function access to env object with DB binding
  const result = await seedArmor();
  res.json({ message: result});
});

export default router;