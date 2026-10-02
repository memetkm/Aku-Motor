import { PartStatus } from "../enums/PartStatus";
import { PartType } from "../enums/PartType";

export interface PartStatusResponse {
  PartId: number;
  PartType: PartType;
  Status: PartStatus;
  RemainingKilometer: number;
  RemainingDays: number;
  ConsequenceSummary: string;
  CostNow: number;
  CostLater: number;
  Message: string;
}
