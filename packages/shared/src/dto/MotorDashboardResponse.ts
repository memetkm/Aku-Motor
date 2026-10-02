import { Motor } from "../models/Motor";
import { PartStatusResponse } from "./PartStatusResponse";

export interface MotorDashboardResponse {
  Motor: Motor;
  TotalParts: number;
  SafeParts: number;
  WarningParts: number;
  UrgentParts: number;
  TotalServiceHistory: number;
  LastServiceAt: string | null;
  Parts: PartStatusResponse[];
}
