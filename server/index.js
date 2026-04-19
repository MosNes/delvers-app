
import { env } from "cloudflare:workers";
import { httpServerHandler } from "cloudflare:node";
import express from "express";
import seedRouter from "./routes/seed_routes.js";

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