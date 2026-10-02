export enum PartStatus {
  Aman = "AMAN",
  Perhatian = "PERHATIAN",
  Segera = "SEGERA"
}

export const PartStatusLabels: Record<PartStatus, string> = {
  [PartStatus.Aman]: "Aman",
  [PartStatus.Perhatian]: "Perhatian",
  [PartStatus.Segera]: "Segera"
};