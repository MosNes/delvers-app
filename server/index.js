
import { env } from "cloudflare:workers";
import { httpServerHandler } from "cloudflare:node";
import express from "express";
import { seedArmor } from "../seeds/seed-dev.js"

const app = express();

// Middleware to parse JSON bodies
app.use(express.json());

// Health check endpoint
app.get("/api", (req, res) => {
  res.json({ message: "The Delvers Express.js API Server is running on Cloudflare Workers!" });
});

app.post("/api/seed/armor", async (req, res) => {
  //pass in env to give seed function access to env object with DB binding
  const result = await seedArmor(env);
  res.json({ message: result});
})



app.listen(3000);
export default httpServerHandler({ port: 3000 });