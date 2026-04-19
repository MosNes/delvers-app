
import { env } from "cloudflare:workers";
import { httpServerHandler } from "cloudflare:node";
import express from "express";
import { seedArmor } from "../seeds/seed-dev.js";
import seedRouter from "./routes/seed_routes.js";

// declare DB as global variable so that nested route functions can access the DB object
const DB = env.DB;

const app = express();

// Middleware to parse JSON bodies
app.use(express.json());

// Health check endpoint
app.get("/api", (req, res) => {
  res.json({ message: "The Delvers Express.js API Server is running on Cloudflare Workers!" });
});

// Routes for Seeding the database
app.use("/api/seed", seedRouter);

app.listen(3000);
export default httpServerHandler({ port: 3000 });