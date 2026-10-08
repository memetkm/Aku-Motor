import { PartType } from "../enums/PartType";

export interface PartEducation {
  Id: number;
  PartType: PartType;
  MotorBrand: string | null;
  MotorModel: string | null;
  ConsequenceLight: string;
  ConsequenceMedium: string;
  ConsequenceFatal: string;
  CostNow: number;
  CostLater: number;
  CreatedAt: string;
}
