export enum DrivingStyle {
  Santai = "Santai",
  Normal = "Normal",
  Agresif = "Agresif"
}

export const DrivingStyleLabels: Record<DrivingStyle, string> = {
  [DrivingStyle.Santai]: "Santai",
  [DrivingStyle.Normal]: "Normal",
  [DrivingStyle.Agresif]: "Agresif"
};