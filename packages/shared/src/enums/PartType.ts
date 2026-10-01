export enum PartType {
  OliMesin = "OliMesin",
  Vbelt = "Vbelt",
  RollerCvt = "RollerCvt",
  KampasRem = "KampasRem",
  Aki = "Aki",
  Ban = "Ban",
  Rantai = "Rantai",
  FilterUdara = "FilterUdara"
}

export const PartTypeLabels: Record<PartType, string> = {
  [PartType.OliMesin]: "Oli Mesin",
  [PartType.Vbelt]: "V-Belt",
  [PartType.RollerCvt]: "Roller CVT",
  [PartType.KampasRem]: "Kampas Rem",
  [PartType.Aki]: "Aki",
  [PartType.Ban]: "Ban",
  [PartType.Rantai]: "Rantai",
  [PartType.FilterUdara]: "Filter Udara"
};