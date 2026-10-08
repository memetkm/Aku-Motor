import { Router } from "express";
import { z } from "zod";
import { Prisma } from "../prisma";
import { CalculatePartStatus } from "../services/partStatusService";

export const ServiceHistoryRoutes = Router({ mergeParams: true });
const HistoryBody = z.object({
  PartId: z.coerce.number().int().positive(),
  ReplacedAt: z.coerce.date(),
  ReplacedKilometer: z.coerce.number().int().min(0),
  Cost: z.coerce.number().int().min(0),
  Notes: z.string().trim().max(1000).optional().nullable()
});

ServiceHistoryRoutes.get("/", async (request, response) => {
  response.json(await Prisma.serviceHistory.findMany({
    where: { MotorId: Number(request.params.MotorId) }, orderBy: { ReplacedAt: "desc" }
  }));
});

ServiceHistoryRoutes.post("/", async (request, response) => {
  const MotorId = Number(request.params.MotorId);
  const parsed = HistoryBody.safeParse(request.body);
  if (!parsed.success) return response.status(400).json({ Message: "Data riwayat belum valid.", Errors: parsed.error.flatten() });
  const part = await Prisma.part.findFirst({ where: { Id: parsed.data.PartId, MotorId }, include: { Motor: true } });
  if (!part) return response.status(404).json({ Message: "Part tidak ditemukan pada motor ini." });
  const profile = await Prisma.usageProfile.findUnique({ where: { MotorId } });
  const nextPart = { ...part, LastReplacedAt: parsed.data.ReplacedAt, LastReplacedKilometer: parsed.data.ReplacedKilometer };
  const status = CalculatePartStatus(nextPart, profile).Status;
  try {
    const created = await Prisma.$transaction(async (transaction) => {
      const history = await transaction.serviceHistory.create({ data: {
        MotorId, PartId: part.Id, PartType: part.PartType, ...parsed.data
      } });
      await transaction.part.update({ where: { Id: part.Id }, data: {
        LastReplacedAt: parsed.data.ReplacedAt,
        LastReplacedKilometer: parsed.data.ReplacedKilometer,
        Status: status
      } });
      await transaction.motor.update({ where: { Id: MotorId }, data: { UpdatedAt: new Date() } });
      return history;
    });
    response.status(201).json(created);
  } catch {
    response.status(409).json({ Message: "Riwayat servis yang sama sudah tercatat." });
  }
});
