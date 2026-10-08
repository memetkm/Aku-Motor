import { PartType } from "../enums/PartType";

export interface ServiceHistory {
  Id: number;
  MotorId: number;
  PartId: number;
  PartType: PartType;
  ReplacedAt: string;
  ReplacedKilometer: number;
  Cost: number;
  Notes: string | null;
  CreatedAt: string;
}
