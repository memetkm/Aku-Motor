import { PartStatus } from "../enums/PartStatus";
import { PartType } from "../enums/PartType";

export interface Part {
  Id: number;
  MotorId: number;
  PartType: PartType;
  LastReplacedAt: string;
  LastReplacedKilometer: number;
  IntervalKilometer: number;
  IntervalMonth: number;
  Status: PartStatus;
  CreatedAt: string;
  UpdatedAt: string;
}
