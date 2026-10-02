import cors from "cors";
import express, { NextFunction, Request, Response } from "express";
import { DashboardRoutes } from "./routes/dashboardRoutes";
import { EducationRoutes, PartEducationRoutes } from "./routes/educationRoutes";
import { MotorRoutes } from "./routes/motorRoutes";
import { MotorPartRoutes, PartRoutes } from "./routes/partRoutes";
import { ServiceHistoryRoutes } from "./routes/serviceHistoryRoutes";
import { UsageProfileRoutes } from "./routes/usageProfileRoutes";

export const App = express();
App.use(cors());
App.use(express.json());
App.get("/api/health", (_request, response) => response.json({ Status: "ok" }));
App.use("/api/motors", MotorRoutes);
App.use("/api/motors/:MotorId/parts", MotorPartRoutes);
App.use("/api/parts", PartRoutes);
App.use("/api/motors/:MotorId/service-history", ServiceHistoryRoutes);
App.use("/api/motors/:MotorId/usage-profile", UsageProfileRoutes);
App.use("/api/motors/:MotorId/dashboard", DashboardRoutes);
App.use("/api/part-education", EducationRoutes);
App.use("/api/parts", PartEducationRoutes);
App.use((error: Error, _request: Request, response: Response, _next: NextFunction) => {
  console.error(error);
  response.status(500).json({ Message: "Terjadi kesalahan pada server." });
});
