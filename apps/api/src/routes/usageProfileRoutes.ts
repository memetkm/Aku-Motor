import { DrivingStyle, Terrain } from "@aku-motor/shared";
import { Router } from "express";
import { z } from "zod";
import { Prisma } from "../prisma";

export const UsageProfileRoutes = Router({ mergeParams: true });
const ProfileBody = z.object({
  KilometerPerDay: z.coerce.number().int().positive(),
  Terrain: z.nativeEnum(Terrain),
  DrivingStyle: z.nativeEnum(DrivingStyle),
  OftenPassenger: z.boolean(),
  OftenRain: z.boolean()
});

UsageProfileRoutes.get("/", async (request, response) => {
  const profile = await Prisma.usageProfile.findUnique({ where: { MotorId: Number(request.params.MotorId) } });
  if (!profile) return response.status(404).json({ Message: "Profil pemakaian belum dibuat." });
  response.json(profile);
});

UsageProfileRoutes.put("/", async (request, response) => {
  const MotorId = Number(request.params.MotorId);
  const parsed = ProfileBody.safeParse(request.body);
  if (!parsed.success) return response.status(400).json({ Message: "Profil pemakaian belum valid.", Errors: parsed.error.flatten() });
  const motor = await Prisma.motor.findUnique({ where: { Id: MotorId } });
  if (!motor) return response.status(404).json({ Message: "Motor tidak ditemukan." });
  const profile = await Prisma.usageProfile.upsert({
    where: { MotorId }, update: parsed.data, create: { MotorId, ...parsed.data }
  });
  await Prisma.motor.update({ where: { Id: MotorId }, data: { UpdatedAt: new Date() } });
  response.json(profile);
});
