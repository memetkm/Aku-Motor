import { Router } from "express";
import { z } from "zod";
import { Prisma } from "../prisma";

export const MotorRoutes = Router();
const MotorBody = z.object({
  Brand: z.string().trim().min(1),
  Model: z.string().trim().min(1),
  Year: z.coerce.number().int().min(1950).max(2100),
  CurrentKilometer: z.coerce.number().int().min(0)
});

MotorRoutes.get("/", async (_request, response) => {
  response.json(await Prisma.motor.findMany({ orderBy: { UpdatedAt: "desc" } }));
});

MotorRoutes.post("/", async (request, response) => {
  const parsed = MotorBody.safeParse(request.body);
  if (!parsed.success) return response.status(400).json({ Message: "Data motor belum valid.", Errors: parsed.error.flatten() });
  response.status(201).json(await Prisma.motor.create({ data: parsed.data }));
});

MotorRoutes.get("/:Id", async (request, response) => {
  const motor = await Prisma.motor.findUnique({ where: { Id: Number(request.params.Id) } });
  if (!motor) return response.status(404).json({ Message: "Motor tidak ditemukan." });
  response.json(motor);
});

MotorRoutes.put("/:Id", async (request, response) => {
  const parsed = MotorBody.safeParse(request.body);
  if (!parsed.success) return response.status(400).json({ Message: "Data motor belum valid.", Errors: parsed.error.flatten() });
  const existing = await Prisma.motor.findUnique({ where: { Id: Number(request.params.Id) } });
  if (!existing) return response.status(404).json({ Message: "Motor tidak ditemukan." });
  response.json(await Prisma.motor.update({ where: { Id: existing.Id }, data: parsed.data }));
});

MotorRoutes.delete("/:Id", async (request, response) => {
  const Id = Number(request.params.Id);
  const historyCount = await Prisma.serviceHistory.count({ where: { MotorId: Id } });
  if (historyCount) return response.status(409).json({ Message: "Motor dengan riwayat servis tidak boleh dihapus." });
  const existing = await Prisma.motor.findUnique({ where: { Id } });
  if (!existing) return response.status(404).json({ Message: "Motor tidak ditemukan." });
  await Prisma.motor.delete({ where: { Id } });
  response.status(204).send();
});
