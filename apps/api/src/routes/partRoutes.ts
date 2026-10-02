import { PartType } from "@aku-motor/shared";
import { Router } from "express";
import { z } from "zod";
import { Prisma } from "../prisma";
import { CalculatePartStatus } from "../services/partStatusService";

export const MotorPartRoutes = Router({ mergeParams: true });
export const PartRoutes = Router();
const PartBody = z.object({
  PartType: z.nativeEnum(PartType),
  LastReplacedAt: z.coerce.date(),
  LastReplacedKilometer: z.coerce.number().int().min(0),
  IntervalKilometer: z.coerce.number().int().positive(),
  IntervalMonth: z.coerce.number().int().positive()
});

async function RecomputePart(Id: number) {
  const part = await Prisma.part.findUnique({ where: { Id }, include: { Motor: true } });
  if (!part) return null;
  const profile = await Prisma.usageProfile.findUnique({ where: { MotorId: part.MotorId } });
  const status = CalculatePartStatus(part, profile).Status;
  return Prisma.part.update({ where: { Id }, data: { Status: status } });
}

MotorPartRoutes.get("/", async (request, response) => {
  const MotorId = Number(request.params.MotorId);
  const parts = await Prisma.part.findMany({ where: { MotorId }, include: { Motor: true }, orderBy: { PartType: "asc" } });
  const profile = await Prisma.usageProfile.findUnique({ where: { MotorId } });
  await Promise.all(parts.map((part) => Prisma.part.update({
    where: { Id: part.Id }, data: { Status: CalculatePartStatus(part, profile).Status }
  })));
  response.json(await Prisma.part.findMany({ where: { MotorId }, orderBy: { PartType: "asc" } }));
});

MotorPartRoutes.post("/", async (request, response) => {
  const MotorId = Number(request.params.MotorId);
  const parsed = PartBody.safeParse(request.body);
  if (!parsed.success) return response.status(400).json({ Message: "Data part belum valid.", Errors: parsed.error.flatten() });
  const motor = await Prisma.motor.findUnique({ where: { Id: MotorId } });
  if (!motor) return response.status(404).json({ Message: "Motor tidak ditemukan." });
  const created = await Prisma.part.create({ data: { MotorId, ...parsed.data } });
  await Prisma.motor.update({ where: { Id: MotorId }, data: { UpdatedAt: new Date() } });
  response.status(201).json(await RecomputePart(created.Id));
});

PartRoutes.put("/:Id", async (request, response) => {
  const Id = Number(request.params.Id);
  const parsed = PartBody.safeParse(request.body);
  if (!parsed.success) return response.status(400).json({ Message: "Data part belum valid.", Errors: parsed.error.flatten() });
  const existing = await Prisma.part.findUnique({ where: { Id } });
  if (!existing) return response.status(404).json({ Message: "Part tidak ditemukan." });
  await Prisma.part.update({ where: { Id }, data: parsed.data });
  await Prisma.motor.update({ where: { Id: existing.MotorId }, data: { UpdatedAt: new Date() } });
  response.json(await RecomputePart(Id));
});

PartRoutes.delete("/:Id", async (request, response) => {
  const Id = Number(request.params.Id);
  const existing = await Prisma.part.findUnique({ where: { Id } });
  if (!existing) return response.status(404).json({ Message: "Part tidak ditemukan." });
  if (await Prisma.serviceHistory.count({ where: { PartId: Id } })) {
    return response.status(409).json({ Message: "Part dengan riwayat servis tidak boleh dihapus." });
  }
  await Prisma.part.delete({ where: { Id } });
  await Prisma.motor.update({ where: { Id: existing.MotorId }, data: { UpdatedAt: new Date() } });
  response.status(204).send();
});
