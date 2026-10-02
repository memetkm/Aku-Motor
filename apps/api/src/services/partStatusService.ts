import { PartStatus, PartStatusResponse, PartType } from "@aku-motor/shared";
import { Part, PartEducation, UsageProfile } from "@prisma/client";

type StatusInput = Part & { Motor: { CurrentKilometer: number }; };

function UsageFactor(profile: UsageProfile | null): number {
  if (!profile) return 1;
  let factor = 1;
  if (profile.Terrain !== "Datar") factor -= 0.08;
  if (profile.DrivingStyle === "Agresif") factor -= 0.1;
  if (profile.OftenPassenger) factor -= 0.05;
  if (profile.OftenRain) factor -= 0.04;
  return Math.max(0.65, factor);
}

export function CalculatePartStatus(part: StatusInput, profile: UsageProfile | null): {
  Status: PartStatus; RemainingKilometer: number; RemainingDays: number;
} {
  const factor = UsageFactor(profile);
  const kilometerLimit = Math.round(part.IntervalKilometer * factor);
  const usedKilometer = part.Motor.CurrentKilometer - part.LastReplacedKilometer;
  const remainingKilometer = kilometerLimit - usedKilometer;
  const dateLimit = new Date(part.LastReplacedAt);
  dateLimit.setMonth(dateLimit.getMonth() + Math.max(1, Math.round(part.IntervalMonth * factor)));
  const remainingDays = Math.ceil((dateLimit.getTime() - Date.now()) / 86_400_000);
  const kmRatio = remainingKilometer / Math.max(1, kilometerLimit);
  const dayRatio = remainingDays / Math.max(1, part.IntervalMonth * 30);
  const lowestRatio = Math.min(kmRatio, dayRatio);
  const Status = lowestRatio <= 0.05 ? PartStatus.Segera : lowestRatio <= 0.2 ? PartStatus.Perhatian : PartStatus.Aman;
  return { Status, RemainingKilometer: remainingKilometer, RemainingDays: remainingDays };
}

export function ToPartStatusResponse(
  part: StatusInput,
  profile: UsageProfile | null,
  education: PartEducation | null
): PartStatusResponse {
  const result = CalculatePartStatus(part, profile);
  const message = result.Status === PartStatus.Aman
    ? "Kondisi masih aman berdasarkan jarak dan waktu pemakaian."
    : result.Status === PartStatus.Perhatian
      ? "Mendekati jadwal penggantian. Siapkan pemeriksaan atau servis."
      : "Sudah sangat dekat atau melewati batas. Segera lakukan penggantian.";
  return {
    PartId: part.Id,
    PartType: part.PartType as PartType,
    ...result,
    ConsequenceSummary: education?.ConsequenceLight ?? "Performa dan keselamatan motor dapat menurun.",
    CostNow: education?.CostNow ?? 0,
    CostLater: education?.CostLater ?? 0,
    Message: message
  };
}
