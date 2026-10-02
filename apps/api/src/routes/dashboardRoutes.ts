import { PartStatus } from "@aku-motor/shared";
import { Router } from "express";
import { Prisma } from "../prisma";
import { FindEducation } from "../services/educationService";
import { ToPartStatusResponse } from "../services/partStatusService";

export const DashboardRoutes = Router({ mergeParams: true });

DashboardRoutes.get("/", async (request, response) => {
  const MotorId = Number(request.params.MotorId);
  const motor = await Prisma.motor.findUnique({ where: { Id: MotorId } });
  if (!motor) return response.status(404).json({ Message: "Motor tidak ditemukan." });
  const [parts, profile, histories] = await Promise.all([
    Prisma.part.findMany({ where: { MotorId }, include: { Motor: true } }),
    Prisma.usageProfile.findUnique({ where: { MotorId } }),
    Prisma.serviceHistory.findMany({ where: { MotorId }, orderBy: { ReplacedAt: "desc" } })
  ]);
  const statuses = await Promise.all(parts.map(async (part) => {
    const { Education } = await FindEducation(part.PartType, motor.Brand, motor.Model);
    return ToPartStatusResponse(part, profile, Education);
  }));
  await Promise.all(statuses.map((item) => Prisma.part.update({
    where: { Id: item.PartId }, data: { Status: item.Status }
  })));
  response.json({
    Motor: motor,
    TotalParts: statuses.length,
    SafeParts: statuses.filter((item) => item.Status === PartStatus.Aman).length,
    WarningParts: statuses.filter((item) => item.Status === PartStatus.Perhatian).length,
    UrgentParts: statuses.filter((item) => item.Status === PartStatus.Segera).length,
    TotalServiceHistory: histories.length,
    LastServiceAt: histories[0]?.ReplacedAt ?? null,
    Parts: statuses
  });
});
