import { DrivingStyle } from "../enums/DrivingStyle";
import { Terrain } from "../enums/Terrain";

export interface UsageProfile {
  Id: number;
  MotorId: number;
  KilometerPerDay: number;
  Terrain: Terrain;
  DrivingStyle: DrivingStyle;
  OftenPassenger: boolean;
  OftenRain: boolean;
  CreatedAt: string;
  UpdatedAt: string;
}
